# discourse-dmon



## Installation

Follow [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157)

Installation
Add this repository's git clone url to your container's app.yml file, at the bottom of the cmd section:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/R45hk4r/DMon.git
```


Rebuild your container:

```
cd /var/discourse
./launcher rebuild app
```

## Configuration

Once you've installed the plugin and restarted your Discourse, you will see a new plugin available in your admin configuration. Click the Settings button next to the discourse-dmon plugin.


## Usage

## Feedback

If you have issues or suggestions for the plugin, please open an issue.
