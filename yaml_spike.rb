require 'Yaml'

ad = [{'title' => 'ad_title',
  'description' => 'ad_description',
 },
 {'title' => 'title2',
  'description' => 'desc2'
 }
]
  
yamlFile = File.new('./hey.yaml', 'w+')
yamlFile.write(ad.to_yaml)
yamlFile.close

adFromYaml = YAML.load_file('./hey.yaml')
puts adFromYaml.inspect
