# hiroshima.yude.jp
🐬 All Docker containers running on [hiroshima.yude.jp](https://hiroshima.yude.jp).

## Overleaf: Installing TeX Live (Full)
```bash
cd overleaf; docker compose exec -it sharelatex bash
tlmgr update --self
tlmgr install scheme-full
exit
docker commit sharelatex sharelatex/sharelatex:with-texlive-full
```

## License
MIT License