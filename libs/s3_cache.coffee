class exports.S3Cache

  constructor: (settings) ->
    @bucket = settings.bucket
    @cache_name = settings.cache
    AWS = require('aws-sdk')
    @s3 = new AWS.S3
      accessKeyId: settings.aws_access_key_id
      secretAccessKey: settings.aws_secret_access_key
      sslEnabled: true


  writeCache: (options) ->
    settings =
      ACL: 'private'
      Body: options.data
      Bucket: @bucket
      Key: @s3Key(options)
      StorageClass: 'REDUCED_REDUNDANCY'

    settings.ServerSideEncryption = 'aes256' if options?.encrypt

    @s3.putObject(settings, options.callback)


  checkCache: (options) ->
    @checkCacheCallback = options.callback

    settings =
      Bucket: @bucket
      Key: @s3Key(options)

    @s3.getObject(settings, @getObjectCallback)


  getObjectCallback: (err, data) =>
    if err
      @checkCacheCallback(err, data)
    else
      @checkCacheCallback(null, data.Body)


  s3Key: (options) ->
    options.version ||= ''
    key = "#{@cache_name}/#{options.key}/#{options.version}"
    key.replace(/\/$/, '').replace(/\/$/, '')

