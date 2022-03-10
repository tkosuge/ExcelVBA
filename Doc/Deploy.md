## ※※※ 古い情報なので注意 ※※※

Singularity化にともないデプロイ方法が変わったため以下を参照してください。

[[デプロイ手順]]


## 前提
- Ruby 1.9.3 がインストールされていること
- ssh で w3deasy ユーザで web01.ddbj.nig.ac.jp 〜 web12.ddbj.nig.ac.jp にアクセスできること

以下が可能
```sh
$ ssh w3deasy@web11.ddbj.nig.ac.jp
Last login: Thu Mar  5 17:18:07 2015 from 133.39.225.64
[w3deasy@t343 ~]$ 
```

## Deasy のインストール

Deasyのデプロイはローカルから実施し、
Webアプリケーションに内包されている Capistorano というツールを使います。
そのため、ローカルに Deasy のインストールが必要です。

```sh
$ gem install bundler
$ git clone git@github.com:ddbj/sakura.git
$ cd sakura
$ bundle
```

## デプロイする
上記まで完了していると、アプリルートからデプロイが可能です

### ステージング環境へデプロイする

```sh
$ cd /path/to/sakura            # 上記の git clone した sakura ディレクトリに移動
$ bundle exec cap staging deploy
```

途中でブランチを聞かれるので指定します。
(指定無しで Enter を押した場合はデフォルト の develop ブランチをデプロイします)

```sh
branch for deploy: |develop| 
```

### 本番環境へデプロイする

```sh
$ cd /path/to/sakura               # 上記の git clone した sakura ディレクトリに移動
$ bundle exec cap production deploy
```

途中でブランチを聞かれるので指定する。
(指定無しで Enter を押した場合はデフォルト の develop ブランチをデプロイします)

```sh
branch for deploy: |develop| 
```

### deasy.nig.ac.jp に最新コードを配置する

```sh
$ ssh deasy.nig.ac.jp
$ cd apps/sakura
$ pwd
/home/deasy/apps/sakura
$ git pull origin develop
$ bundle
$ bundle exec rails s
```

※ コードに修正がある場合は、マージコミットが発生します。こちらをメインの開発に利用する場合は、commit & push をお忘れなくー


### 参考: Git の運用について

本プロジェクトでは基本的に develop ブランチ がベースになります。
`git clone git@github.com:ddbj/sakura.git` した直後も develop ブランチになります。

開発はお好きにトピックブランチをご用意して頂き、トピックブランチをステージング環境にデプロイして動作確認しても良いですが、
最終的に develop ブランチにマージして、develop ブランチを 本番環境にはデプロイするようにして下さい。
