;; Beneficiary Registry Contract
;; Manages beneficiary enrollment, eligibility verification, and identity management

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-BENEFICIARY-EXISTS (err u101))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))
(define-constant ERR-ENROLLMENT-CLOSED (err u104))

;; Data Variables
(define-data-var next-beneficiary-id uint u1)
(define-data-var enrollment-open bool true)
(define-data-var total-beneficiaries uint u0)

;; Data Maps
(define-map beneficiaries
  { beneficiary-id: uint }
  {
    name-hash: (buff 32),
    email-hash: (buff 32),
    age: uint,
    household-size: uint,
    annual-income: uint,
    enrollment-date: uint,
    status: (string-ascii 20),
    verification-level: uint,
    last-updated: uint
  }
)

(define-map beneficiary-lookup
  { email-hash: (buff 32) }
  { beneficiary-id: uint }
)

(define-map authorized-agencies
  { agency: principal }
  { authorized: bool }
)

;; Authorization Functions
(define-private (is-authorized (caller principal))
  (or
    (is-eq caller CONTRACT-OWNER)
    (default-to false (get authorized (map-get? authorized-agencies { agency: caller })))
  )
)

;; Administrative Functions
(define-public (authorize-agency (agency principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-agencies { agency: agency } { authorized: true }))
  )
)

(define-public (revoke-agency (agency principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-agencies { agency: agency } { authorized: false }))
  )
)

(define-public (toggle-enrollment)
  (begin
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (ok (var-set enrollment-open (not (var-get enrollment-open))))
  )
)

;; Core Functions
(define-public (enroll-beneficiary
  (name (string-ascii 100))
  (email (string-ascii 100))
  (age uint)
  (household-size uint)
  (annual-income uint)
)
  (let
    (
      (beneficiary-id (var-get next-beneficiary-id))
      (name-hash (keccak256 (unwrap-panic (to-consensus-buff? name))))
      (email-hash (keccak256 (unwrap-panic (to-consensus-buff? email))))
      (current-block block-height)
    )
    (asserts! (var-get enrollment-open) ERR-ENROLLMENT-CLOSED)
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> age u0) ERR-INVALID-INPUT)
    (asserts! (> household-size u0) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? beneficiary-lookup { email-hash: email-hash })) ERR-BENEFICIARY-EXISTS)

    (map-set beneficiaries
      { beneficiary-id: beneficiary-id }
      {
        name-hash: name-hash,
        email-hash: email-hash,
        age: age,
        household-size: household-size,
        annual-income: annual-income,
        enrollment-date: current-block,
        status: "pending",
        verification-level: u1,
        last-updated: current-block
      }
    )

    (map-set beneficiary-lookup
      { email-hash: email-hash }
      { beneficiary-id: beneficiary-id }
    )

    (var-set next-beneficiary-id (+ beneficiary-id u1))
    (var-set total-beneficiaries (+ (var-get total-beneficiaries) u1))

    (ok beneficiary-id)
  )
)

(define-public (update-beneficiary-status
  (beneficiary-id uint)
  (new-status (string-ascii 20))
)
  (let
    (
      (beneficiary (unwrap! (map-get? beneficiaries { beneficiary-id: beneficiary-id }) ERR-BENEFICIARY-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)

    (ok (map-set beneficiaries
      { beneficiary-id: beneficiary-id }
      (merge beneficiary {
        status: new-status,
        last-updated: block-height
      })
    ))
  )
)

(define-public (update-verification-level
  (beneficiary-id uint)
  (level uint)
)
  (let
    (
      (beneficiary (unwrap! (map-get? beneficiaries { beneficiary-id: beneficiary-id }) ERR-BENEFICIARY-NOT-FOUND))
    )
    (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= level u5) ERR-INVALID-INPUT)

    (ok (map-set beneficiaries
      { beneficiary-id: beneficiary-id }
      (merge beneficiary {
        verification-level: level,
        last-updated: block-height
      })
    ))
  )
)

;; Read-only Functions
(define-read-only (get-beneficiary (beneficiary-id uint))
  (map-get? beneficiaries { beneficiary-id: beneficiary-id })
)

(define-read-only (get-beneficiary-by-email-hash (email-hash (buff 32)))
  (match (map-get? beneficiary-lookup { email-hash: email-hash })
    lookup (map-get? beneficiaries { beneficiary-id: (get beneficiary-id lookup) })
    none
  )
)

(define-read-only (get-total-beneficiaries)
  (var-get total-beneficiaries)
)

(define-read-only (is-enrollment-open)
  (var-get enrollment-open)
)

(define-read-only (is-agency-authorized (agency principal))
  (default-to false (get authorized (map-get? authorized-agencies { agency: agency })))
)
