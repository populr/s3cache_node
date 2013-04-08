class exports.S3Cache

  constructor: (cache_name, aws_access_key_id, aws_secret_access_key) ->
    @name = cache_name
    AWS = require('aws-sdk')
    @s3 = new AWS.S3.Client
      accessKeyId: 'aws_access_key_id'
      secretAccessKey: 'aws_secret_access_key'
      sslEnabled: true


  writeCache: (options) ->
    settings =
      ACL: 'private'
      Body: options.data
      Bucket: @name
      Key: @s3Key(options)
      StorageClass: 'reduced-redundancy'

    settings.ServerSideEncryption = 'aes256' if options?.encrypt

    @s3.putObject(settings, options.callback)


  checkCache: (options) ->
    settings =
      Bucket: @name
      Key: @s3Key(options)

    @s3.getObject(settings, options.callback)


  s3Key: (options) ->
    options.version ||= ''
    key = "#{options.key}/#{options.version}"
    key.replace(/\/$/, '').replace(/\/$/, '')

