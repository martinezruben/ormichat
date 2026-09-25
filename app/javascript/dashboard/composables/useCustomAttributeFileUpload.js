import { DirectUpload } from 'activestorage';
import { setDirectUploadAuthHeaders } from 'dashboard/helper/directUploadsHelper';

// Builds a stable, permanent URL for an ActiveStorage blob from the
// signed_id/filename returned by the direct upload endpoint. It uses the
// proxy route Rails mounts by default (`rails_service_blob_proxy`), which
// streams the file through the app instead of redirecting to an expiring
// storage URL, so copied links keep working.
const buildBlobUrl = blob =>
  `/rails/active_storage/blobs/proxy/${blob.signed_id}/${encodeURIComponent(blob.filename)}`;

/**
 * Uploads a file directly to storage for a custom attribute of type "file"
 * and resolves to the URL that should be stored as the attribute's value.
 * @param {String} directUploadUrl - account-scoped direct_uploads endpoint
 * @param {File} file
 * @returns {Promise<String>} resolvable URL for the uploaded file
 */
export const useCustomAttributeFileUpload = () => {
  const uploadFile = (directUploadUrl, file) =>
    new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, directUploadUrl, {
        directUploadWillCreateBlobWithXHR: xhr => {
          setDirectUploadAuthHeaders(xhr);
        },
      });

      upload.create((error, blob) => {
        if (error) {
          reject(error);
        } else {
          resolve(buildBlobUrl(blob));
        }
      });
    });

  return { uploadFile };
};
