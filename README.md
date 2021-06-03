# Generate JWT of Google Service Account

## Usage Example

```yaml
- uses: KMConner/google-jwt-gen@v1
  id: gen-jwt
  with:
    service-account: ${{ secrets.GOOGLE_SERVICE_ACCOUNT }}
    scope: "https://www.googleapis.com/auth/drive"
```
