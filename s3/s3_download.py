import boto3
import fire
from boto3.s3.transfer import TransferConfig


def download_file(bucket, key,  dst_path, version_id = None, chunk_size_mb=16, max_concurrency=16, multipart_threshold_mb=8):
    cfg = TransferConfig(
        multipart_threshold=multipart_threshold_mb * 1024 * 1024,
        multipart_chunksize=chunk_size_mb * 1024 * 1024,
        max_concurrency=max_concurrency,  # threads
        use_threads=True,
    )
    s3 = boto3.client("s3")
    extra_args = {}
    if version_id:
        extra_args["VersionId"] = version_id
    s3.download_file(bucket, key, dst_path, ExtraArgs=extra_args, Config=cfg)


if __name__ == "__main__":
    fire.Fire(download_file)