# -*- coding: utf-8 -*- 

# ※「../etc/auth.yaml」を作成し、以下の内容を設定しておくこと。
# <pre>
# ---
# user: <クリック証券のアクセスユーザー名>
# pass: <クリック証券のアクセスユーザーパスワード>
# demo_user: <クリック証券デモ取引のアクセスユーザー名>
# demo_pass: <クリック証券デモ取引のアクセスユーザーパスワード>
# </pre>
require 'yaml'

auth = YAML.load_file "#{File.dirname(__FILE__)}/../etc/auth.yaml"
USER=auth["user"]
PASS=auth["pass"]
DEMO_USER=auth["demo_user"]
DEMO_PASS=auth["demo_pass"]