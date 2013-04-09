require('./spec_helper')
S3Cache = require('../libs/s3_cache').S3Cache

describe "S3Cache", ->

  describe "#constructor", ->
    it "should use the aws credentials to initialize an aws sdk object", ->
      AWS = stubModule('aws-sdk')
      spyOn(AWS.S3, 'Client')

      cache = new S3Cache(bucket: 'bucket_name', cache: 'cache_name', aws_access_key_id: 'aws_access_key_id', aws_secret_access_key: 'aws_secret_access_key')

      expect(AWS.S3.Client).toHaveBeenCalledWith
        accessKeyId: 'aws_access_key_id'
        secretAccessKey: 'aws_secret_access_key'
        sslEnabled: true


    it "should save the cache name", ->
      cache = new S3Cache(bucket: 'bucket_name', cache: 'cache_name', aws_access_key_id: 'aws_access_key_id', aws_secret_access_key: 'aws_secret_access_key')
      expect(cache.cache_name).toEqual 'cache_name'


  describe "#s3Key", ->
    beforeEach ->
      @cache = new S3Cache(bucket: 'bucket_name', cache: 'cache_name', aws_access_key_id: 'aws_access_key_id', aws_secret_access_key: 'aws_secret_access_key')

    it "should create a key from the cache_name, options, and version", ->
      options =
        key: 'hello_world'
        version: '2'
      expect(@cache.s3Key(options)).toEqual('cache_name/hello_world/2')


    describe "when the version is null", ->

      it "should omit the version from the key", ->
        options =
          key: 'hello_world'
        expect(@cache.s3Key(options)).toEqual('cache_name/hello_world')


      describe "when the base key ends in a slash", ->
        it "should omit the trailing slash (so that we can navigate to the object in the S3 console)", ->
          options =
            key: 'hello_world/'
          expect(@cache.s3Key(options)).toEqual('cache_name/hello_world')


  describe "#writeCache", ->
    beforeEach ->
      @cache = new S3Cache(bucket: 'bucket_name', cache: 'cache_name', aws_access_key_id: 'aws_access_key_id', aws_secret_access_key: 'aws_secret_access_key')
      @cache.s3Key = ->
        'hello_world/2'
      @spyOn(@cache.s3, 'putObject')
      @callback = ->


    it "should put the cache data to s3 with a key from #s3Key, an acl of private, and a storage class of reduced redundancy", ->
      options =
        data: 'Content to cache'
        callback: @callback

      @cache.writeCache(options)

      expect(@cache.s3.putObject).toHaveBeenCalledWith
        ACL: 'private'
        Body: 'Content to cache'
        Bucket: 'bucket_name'
        Key: 'hello_world/2'
        StorageClass: 'reduced-redundancy'
      , @callback


    describe "when encryption is indicated", ->

      it "should set server side encryption on the object", ->
        options =
          data: 'Content to cache'
          callback: @callback
          encrypt: true

        @cache.writeCache(options)

        expect(@cache.s3.putObject).toHaveBeenCalledWith
          ACL: 'private'
          Body: 'Content to cache'
          Bucket: 'bucket_name'
          Key: 'hello_world/2'
          StorageClass: 'reduced-redundancy'
          ServerSideEncryption: 'aes256'
        , @callback



  describe "#checkCache", ->
    beforeEach ->
      @cache = new S3Cache(bucket: 'bucket_name', cache: 'cache_name', aws_access_key_id: 'aws_access_key_id', aws_secret_access_key: 'aws_secret_access_key')
      @cache.s3Key = ->
        'hello_world/2'
      @spyOn(@cache.s3, 'getObject')
      @callback = ->


    it "should call #getObject on the s3 object with the key returned by #s3Key", ->
      options =
        callback: @callback
      @cache.checkCache(options)

      expect(@cache.s3.getObject).toHaveBeenCalledWith
        Bucket: 'bucket_name'
        Key: 'hello_world/2'
      , @callback

