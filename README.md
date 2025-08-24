# Social Benefit Distribution System

A comprehensive blockchain-based system for managing social benefit distribution, ensuring aid reaches intended recipients through automated verification, fraud prevention, and outcome tracking.

## System Overview

This system consists of five interconnected Clarity smart contracts that work together to provide a complete social benefit distribution platform:

### Core Contracts

1. **beneficiary-registry.clar** - Manages beneficiary enrollment, eligibility verification, and identity management
2. **benefit-calculator.clar** - Handles automated benefit calculations based on eligibility criteria and need assessment
3. **payment-distributor.clar** - Manages secure payment distribution and transaction tracking
4. **fraud-detector.clar** - Implements fraud prevention mechanisms and identity verification
5. **outcome-tracker.clar** - Tracks program effectiveness, measures outcomes, and generates reports

## Key Features

### Beneficiary Management
- Secure enrollment process with identity verification
- Eligibility status tracking and updates
- Comprehensive beneficiary profiles with encrypted sensitive data
- Multi-factor verification system

### Automated Benefit Calculation
- Dynamic benefit amount calculation based on multiple factors
- Support for different benefit types (food assistance, housing, healthcare, etc.)
- Household size and income consideration
- Geographic cost-of-living adjustments

### Secure Payment Distribution
- Automated payment scheduling and distribution
- Multiple payment methods support
- Transaction history and audit trails
- Emergency payment capabilities

### Fraud Prevention
- Real-time identity verification
- Duplicate enrollment detection
- Suspicious activity monitoring
- Automated fraud alerts and reporting

### Outcome Tracking
- Program effectiveness measurement
- Beneficiary outcome tracking
- Statistical reporting and analytics
- Inter-agency coordination support

## Technical Architecture

### Data Security
- All sensitive data is hashed and encrypted
- Role-based access control
- Audit trails for all transactions
- Compliance with privacy regulations

### Scalability
- Modular contract design
- Efficient data structures
- Optimized for high transaction volume
- Future-proof architecture

### Integration
- API-ready for external system integration
- Support for multiple agencies
- Standardized data formats
- Real-time synchronization capabilities

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Basic understanding of Clarity smart contracts

### Installation
\`\`\`bash
npm install
clarinet check
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy
\`\`\`

## Contract Interactions

### Enrolling a Beneficiary
```clarity
(contract-call? .beneficiary-registry enroll-beneficiary 
  "John Doe" 
  "john.doe@email.com" 
  u30 
  u2 
  u50000)
