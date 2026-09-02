# INC-006 — Storage validation record

## Validation date

2026-09-02 (Asia/Tbilisi)

## Observed project state

- Project: `supabase-support-lab`
- Bucket: `support-evidence`
- Bucket access model: private
- Storage policy count shown in the dashboard: one
- Policy shown: `authenticated users upload support evidence` (`INSERT`, role `authenticated`)
- No `storage.objects` `SELECT` policy was shown in the dashboard during inspection.

## Test performed

The harmless file `INC-006-upload-validation.txt` was uploaded to the `support-evidence` bucket through the authenticated Supabase dashboard session.

The local client then attempted an unauthenticated upload using the same harmless file.

## Result

- The dashboard displayed: `Successfully uploaded 1 file!`
- The bucket listing displayed `INC-006-upload-validation.txt`.
- The bucket also contained an existing `storage-test.txt` object.
- The unauthenticated client upload was rejected with HTTP `403` and `new row violates row-level security policy`.
- The anonymous test path was `inc-006-client-test-1788340570880-INC-006-upload-validation.txt`.
- The authenticated client sign-in succeeded without displaying or recording the JWT.
- The authenticated client upload succeeded through the `authenticated` policy.
- The authenticated test path was `inc-006-client-test-1788340644093-INC-006-upload-validation.txt`.

## Current conclusion

The anonymous-denial control and authenticated end-user success test both passed. Under the current policy state, an unauthenticated client was denied while a valid authenticated user could upload to the private bucket. The exact client upload flow succeeded with the existing `INSERT` policy; no additional `SELECT` policy was needed for this observed response.

## Evidence limitation

This confirms that the dashboard could create an object, but it does not prove that an ordinary application client using an end-user JWT can upload successfully. The dashboard may use privileged internal access. A complete end-user validation still requires a client-side or API test with:

1. an unauthenticated request that remains denied;
2. an authenticated user JWT;
3. the exact upload operation and response;
4. confirmation that the object path is within the intended scope; and
5. a check for any `SELECT` policy requirement when Storage returns object metadata.

No credentials, JWTs, or service keys are stored in this repository.
