s3cache_node
============

An S3 backed cache for resources that are expensive to generate but don't warrant storage in an in-memory cache or standard DB (because of size or number and control over persistence). Use S3 lifecycle management to set the duration to hold on to cached resources.


specs
=====
    $ jasmine-node --coffee spec/
