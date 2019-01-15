module RemoteFilesHandler
  extend ActiveSupport::Concern

  def build_remote_file_url(uploader)
    "#{SmartEnv['RAILS_HOST']}#{uploader.url}"
  end

  def local_temp_file(uploader)
    url = build_remote_file_url(uploader)
    content = open(url).read.force_encoding('utf-8')

    tmp = Tempfile.new [name, "#{File.extname uploader.path}"]
    tmp.write content
    tmp.rewind
    tmp
  end
end
