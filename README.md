# OpenAC Example App

Sample iOS app that runs the **OpenAC** zero-knowledge pipeline for Taiwan's MOICA digital identity (自然人憑證): authenticate with the MOICA app (行動自然人憑證), generate ZK proofs for the cert chain (RS4096) and user signature (RS2048) circuits, then submit them to a server for link verification. It uses **[OpenACSwift](https://github.com/privacy-ethereum/OpenACSwift)**—Swift bindings for OpenAC on iOS.

## Demo

|                       Download Circuits                       |                Sign with MOICA                 |                 Generate Proof                 |
| :-----------------------------------------------------------: | :--------------------------------------------: | :--------------------------------------------: |
| ![Download circuits](images/openac-ios-download-circuits.gif) | ![Sign with MOICA](images/openac-ios-sign.gif) | ![Generate proof](images/openac-ios-prove.gif) |
|                          ~10 seconds                          |                  ~11 seconds                   |           prove ~5 s \| verify ~13 s           |

## How it works

The app walks through four stages:

### 1. Setup — Download Circuit files

Downloads three files from cloud storage (shown only when not yet present):

| File                            | Source                        | Size   |
| ------------------------------- | ----------------------------- | ------ |
| `cert_chain_rs4096_proving.key` | zkID releases (gz)            | ~large |
| `user_sig_rs2048_proving.key`   | zkID releases (gz)            | ~large |
| `g3-tree-snapshot.json.gz`      | moica-revocation-smt releases | —      |

### 2. TW FidO / MOICA — Authenticate with national ID

| Step                  | Description                                                                                                                                               |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ID Number**         | Enter your Taiwan national ID (身分證字號) (e.g. `A123456789`)                                                                                                         |
| **TBS**               | To-be-signed challenge bytes. Tap the refresh button to call `POST /challenge` on the server and receive a `challenge_bytes`.                             |
| **Get SP Ticket**     | Calls `POST /fido/sp-ticket` with the ID number and TBS. Returns a signed `sp_ticket`.                                                                    |
| **Verify with MOICA** | Deep-links to `mobilemoica://moica.moi.gov.tw/a2a/verifySign` so the MOICA app performs the signature. Returns to `openac://callback`.                    |
| **Auth Result**       | Calls `POST /fido/ath-result`, polling until the signed response and signer certificate are available.                                                    |
| **Generate Input**    | Calls `generateCertChainRs4096Input` from OpenACSwift to build the circuit input JSON from the MOICA response, issuer certificate, TBS, and SMT snapshot. |

### 3. Pipeline — ZK proof

| Step               | Description                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **Generate Proof** | Runs `proveCertChainRs4096` and `proveUserSigRs2048` (Groth16 provers). Reports time in ms. |
| **Verify**         | Submits proofs to `POST /link-verify` with the challenge ID, cert chain type (`rs4096`).    |

Individual steps can be triggered with their own play button, or tap **Run All Steps** in the toolbar to run prove + verify in sequence.

### Link-verify request format

```json
{
    "cert_chain_type": "rs4096",
    "cert_chain_proof": "<base64-encoded bytes>",
    "user_sig_proof": "<base64-encoded bytes>"
}
```

## Requirements

- iOS 16+
- Xcode 15+
- MOICA app installed on device for the authentication flow
- A running server exposing `/challenge` and `/link-verify` endpoints

## Dependencies

- [OpenACSwift](https://github.com/privacy-ethereum/OpenACSwift) — Swift bindings for `proveCertChainRs4096`, `proveUserSigRs2048`, `verifyCertChainRs4096`, `verifyUserSigRs2048`, `generateCertChainRs4096Input`
- CryptoKit (system) — AES-256-GCM for the sp_checksum required by the TW FidO API
- zlib (system) — decompresses `.gz` key files on-device

## Running the project

### 1. Start the verifier server

Clone and run [go-zkid-verifier](https://github.com/privacy-ethereum/go-zkid-verifier), then expose it via [ngrok](https://ngrok.com):

```bash
# In the go-zkid-verifier directory
make download-keys
make build
make serve
```

```bash
# In a separate terminal
ngrok http 8080
```

ngrok will print a public URL like `https://b33f-54-237-15-198.ngrok-free.app`. Copy it.

### 2. Update the server URLs in the app

Open `OpenACExampleApp/ProofViewModel.swift` and replace the two URL constants near the top of the file with your ngrok URL:

```swift
private let serverURL = URL(string: "https://<your-subdomain>.ngrok-free.app/challenge")!
private let linkVerifyURL = URL(string: "https://<your-subdomain>.ngrok-free.app/link-verify")!
```

### 3. Build and run

1. Open `OpenACExampleApp.xcodeproj` in Xcode.
2. Select a physical iPhone and ensure the [TW FidO app (行動自然人憑證)](https://apps.apple.com/tw/app/%E8%A1%8C%E5%8B%95%E8%87%AA%E7%84%B6%E4%BA%BA%E6%86%91%E8%AD%89/id1462866416) is installed.
3. Build and run.
4. On first launch, tap **Download Circuit** in the Setup section and wait for all three files to download.
5. Tap the refresh button next to **TBS** to fetch a challenge from the server.
6. Enter your ID number(身分證字號), then follow the TW FidO / MOICA steps in order.
7. Tap **Run All Steps** (or individual play buttons) to generate and verify the ZK proofs.

## See also

- [OpenACSwift](https://github.com/privacy-ethereum/OpenACSwift) — API, installation, and prebuilt binaries
- [zkID releases](https://github.com/privacy-ethereum/zkID/releases/tag/RSA-X.509-Cert-latest) — circuit and key files
- [moica-revocation-smt](https://github.com/privacy-ethereum/moica-revocation-smt) — SMT snapshot releases
