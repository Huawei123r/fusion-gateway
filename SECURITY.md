# Security Policy

The security of the Fusion Gateway is a top priority. This document outlines the security model, the trust assumptions inherent in the framework, and the process for responsibly reporting vulnerabilities.

## Security Model & Trust Assumptions

The Fusion Gateway framework is designed with security and decentralization in mind. However, like any system involving administrative controls, there are inherent trust assumptions that users should be aware of.

### Owner Privileges

The core contracts (`Wardstone.sol`, `SchemaForge.sol`, `LoreHooks.sol`) use the `Ownable` pattern from OpenZeppelin. The `owner` of these contracts has the following administrative privileges:

-   **`Wardstone.sol`**: The owner can add and remove authorized API keys. This means the owner controls which keys can be used to secure data-fetching functions.
-   **`SchemaForge.sol`**: The owner can register and update API schemas. This includes setting the URL template and, most importantly, the address of the `responseParser` contract. A malicious owner could potentially change a schema to point to a malicious parser contract.
-   **`LoreHooks.sol`**: The owner can define and modify lore triggers.

**It is therefore critical that users of the Fusion Gateway trust the owner of the deployed contracts.** For a truly decentralized deployment, the ownership of these contracts should be transferred to a multi-sig wallet or a DAO-controlled address.

### Data Sanitization

The `Sanctifier.sol` contract is responsible for cleaning and validating data returned from external APIs. The current implementation provides a basic level of sanitization. Users should be aware of its limitations (e.g., the naive JSON parser) and should perform additional validation within their own application contracts as needed.

## Responsible Vulnerability Reporting

We take all security vulnerabilities seriously. If you discover a security issue, please report it to us privately to protect the project and its users.

**Please do not open a public GitHub issue for security vulnerabilities.**

Instead, please send an email to `[SECURITY_CONTACT_EMAIL]` (this is a placeholder; a real project would have a dedicated security contact).

Please include the following information in your report:

-   A detailed description of the vulnerability.
-   The steps required to reproduce the vulnerability.
-   Any proof-of-concept code.
-   Your name and contact information.

We will acknowledge your report within 48 hours and will work with you to understand and resolve the issue as quickly as possible. We believe in rewarding responsible disclosure and will consider bounties for critical vulnerabilities.

---

This security policy is a living document and may be updated as the project evolves.
