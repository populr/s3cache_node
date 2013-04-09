class exports.S3Cache

  constructor: (settings) ->
    @bucket = settings.bucket
    @cache_name = settings.cache
    AWS = require('aws-sdk')
    @s3 = new AWS.S3.Client
      accessKeyId: settings.aws_access_key_id
      secretAccessKey: settings.aws_secret_access_key
      sslEnabled: true


  writeCache: (options) ->
    settings =
      ACL: 'private'
      Body: options.data
      Bucket: @bucket
      Key: @s3Key(options)
      StorageClass: 'reduced-redundancy'

    settings.ServerSideEncryption = 'aes256' if options?.encrypt

    @s3.putObject(settings, options.callback)


  checkCache: (options) ->
    settings =
      Bucket: @bucket
      Key: @s3Key(options)

    @s3.getObject(settings, options.callback)


  s3Key: (options) ->
    options.version ||= ''
    key = "#{@cache_name}/#{options.key}/#{options.version}"
    key.replace(/\/$/, '').replace(/\/$/, '')

