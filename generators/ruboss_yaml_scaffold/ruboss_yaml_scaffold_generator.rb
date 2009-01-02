require 'yaml'

class RubossYamlScaffoldGenerator < RubiGen::Base
  include Ruboss4Ruby::Configuration

  def extract_attrs(line, attrs)
    attrs.each do |key,value|
      if value.class == Array
        line << " #{key}:#{value.join(',')}"
      else
        line << " #{key}:#{value}"
      end    
    end
    line
  end
  
  def manifest
    record do |m|
      models = YAML.load(File.open(File.join(APP_ROOT, 'db/model.yml'), 'r'))
      models.each do |model|
        line = ""
        attrs = model[1]
        if attrs.class == Array
          attrs.each do |elm|
            line = extract_attrs(line, elm)
          end
        else
          line = extract_attrs(line, attrs)
        end
        line = model[0].camelcase + " " + line
        puts 'running: ruboss_scaffold ' + line
        RubiGen::Scripts::Generate.new.run(line.split, :generator => 'ruboss_scaffold', 
          :gae => options[:gae])
        puts 'done ...'
      end
      RubiGen::Scripts::Generate.new.run(['ruboss_main_app'], :gae => options[:gae])
    end
  end

  protected
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-g", "--gae", "Generate Google App Engine Python classes in addition to Ruboss Flex resources.", 
      "Default: false") { |v| options[:gae] = v }
  end
end