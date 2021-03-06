import "java.lang.Thread"

import "java.io.BufferedReader"
import "java.io.FileInputStream"
import "java.io.InputStreamReader"

import "org.apache.http.HttpEntity"
import "org.apache.http.HttpResponse"
import "org.apache.http.auth.AuthScope"
import "org.apache.http.auth.UsernamePasswordCredentials"
import "org.apache.http.client.HttpClient"
import "org.apache.http.client.methods.HttpPost"
import "org.apache.http.entity.FileEntity"
import "org.apache.http.entity.InputStreamEntity"
import "org.apache.http.entity.ByteArrayEntity"
import "org.apache.http.impl.client.BasicCredentialsProvider"
import "org.apache.http.impl.client.DefaultHttpClient"
import "org.apache.http.util.EntityUtils"

class PophealthImporterThread < Thread

  def initialize
    @shutdown = false
    @import_records = false
    @config = parse_configuration_file
  end

  def run
    # forever loop
    begin
      self.synchronized do
        if @import_records
          @jframe.set_play_mode(true)
          files = @import_directory.listFiles()
          for i in (0..(files.length-1))
            @jframe.select_item(i)
            @jframe.update_text_areas
            httpclient = DefaultHttpClient.new()
            begin
              import_file = java.io.File.new(@jframe.get_file_list.get_selected_value.get_file.get_path)
              reqEntity = FileEntity.new(import_file, "text/xml")
              httppost = HttpPost.new(@config['URL'].to_s)
              credsProvider = BasicCredentialsProvider.new()
              credsProvider.setCredentials(
                AuthScope.new(@config['AUTHSCOPE'], AuthScope::ANY_PORT),
                UsernamePasswordCredentials.new(@config['USER_NAME'], @config['PASSWORD']))
              httpclient.setCredentialsProvider(credsProvider)
              httppost.setEntity(reqEntity)
              puts("executing request " + httppost.getRequestLine().to_s)
              response = httpclient.execute(httppost)
              resEntity = response.getEntity()
              puts(response.getStatusLine().to_s)
            rescue Exception => file_parse_and_upload_exception
              puts "Unrecoverable error parsing file " + i.to_s
              puts "Message #{file_parse_and_upload_exception.message}"
              puts "Backtrace #{file_parse_and_upload_exception.backtrace}"
            end
          end
          @jframe.set_play_mode(false)
          @import_records = false
        end
      end
      # busy polling is set to 1 second
      sleep 1
    end until @shutdown
  end

  def shutdown_importer_thread
    self.synchronized do
      @shutdown = true
    end
  end

  def set_import_records_flag
    self.synchronized do
      @import_records = true
    end
  end

  def set_jframe (jframe)
    self.synchronized do
      @jframe = jframe
    end
  end

  def set_import_directory(import_directory)
    @import_directory = import_directory
    @jframe.set_patient_directory(import_directory)
  end

  def pause
    @import_records = false
  end

  private

  def parse_configuration_file
    config = {}
    File.foreach("config/pophealth.properties") do |line|
      line.strip!
      # Skip comments and whitespace
      if (line[0] != ?# and line =~ /\S/ )
        i = line.index('=')
        if (i)
          config[line[0..i - 1].strip] = line[i + 1..-1].strip
        else
          config[line] = ''
        end
      end
    end
    config
  end

end