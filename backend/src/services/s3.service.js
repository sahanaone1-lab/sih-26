const { S3Client, PutObjectCommand, DeleteObjectsCommand, ListObjectsV2Command, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const env = require('../config/env');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'ap-south-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  }
});

const BUCKET_NAME = process.env.AWS_S3_BUCKET;

const uploadBuffer = async (sessionId, fileBuffer, fileName, mimeType) => {
  const storageKey = `temporary-sessions/${sessionId}/${fileName}`;
  const command = new PutObjectCommand({
    Bucket: BUCKET_NAME,
    Key: storageKey,
    Body: fileBuffer,
    ContentType: mimeType,
  });

  await s3Client.send(command);
  return storageKey;
};

const generatePresignedUrl = async (storageKey, expiresIn = 300) => {
  const command = new GetObjectCommand({
    Bucket: BUCKET_NAME,
    Key: storageKey,
  });

  // URL expires in 5 minutes by default
  const url = await getSignedUrl(s3Client, command, { expiresIn });
  return url;
};

const deleteSessionFolder = async (sessionId) => {
  const prefix = `temporary-sessions/${sessionId}/`;
  
  try {
    const listCommand = new ListObjectsV2Command({
      Bucket: BUCKET_NAME,
      Prefix: prefix,
    });
    
    const listResponse = await s3Client.send(listCommand);
    if (!listResponse.Contents || listResponse.Contents.length === 0) {
      return; // Nothing to delete
    }

    const deleteParams = {
      Bucket: BUCKET_NAME,
      Delete: {
        Objects: listResponse.Contents.map((obj) => ({ Key: obj.Key })),
        Quiet: false,
      },
    };

    const deleteCommand = new DeleteObjectsCommand(deleteParams);
    await s3Client.send(deleteCommand);
  } catch (error) {
    console.error('Error deleting session folder from S3:', error);
    throw error;
  }
};

module.exports = {
  uploadBuffer,
  generatePresignedUrl,
  deleteSessionFolder
};
