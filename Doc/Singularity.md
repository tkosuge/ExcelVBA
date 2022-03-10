## コンテナイメージ(.simgファイル)作成

```
# /vagrant/deasy-dev.simg が作成される
# （他のディレクトリに simg を作成しようとするとディスクスペースが足りないとエラーになるので /vagrant/ に作成してる）
$ vagrant ssh
$ cd ~/src/sakura
$ cd singularity/
$ sudo singularity build /vagrant/deasy-dev.simg Singularity
```