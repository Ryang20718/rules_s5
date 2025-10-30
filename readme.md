# rules_s5

bazel rules to fetch s3 files quickly with [s5cmd](https://github.com/peak/s5cmd) as a repository rule. Modified with heavy inspiration from [cloud_archive](https://github.com/1e100/cloud_archive)


# Quickstart
```bash
load("@rules_s5//s3:archive.bzl", "s3_archive")
s3_archive(
    name = "test_bucket",
    bucket = "<bucket name",
    file_path = "<file path>",
    sha256 = "<sha256sum>",
    file_version = "<fileversion id>",
)
```