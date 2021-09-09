import re
import yaml

YAML_FILE = 'config_docker.yaml'
EXPECT_SCRIPT = 'script.exp'

with open(YAML_FILE, 'r') as stream:
    codes = yaml.load(stream, Loader=yaml.FullLoader)

print(codes['Code'])
with open(EXPECT_SCRIPT, 'r+') as f:
    text = f.read()
    text = re.sub('SN2483424', codes['SerialNumber'], text)
    text = re.sub('Code55381', codes['Code'], text)
    text = re.sub('Auth82847', codes['Authorization'], text)

    f.seek(0)
    f.write(text)
    f.truncate()
