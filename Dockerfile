FROM desktopcontainers/base-debian

ENV TURL="https://www.torproject.org"

RUN export BINARY_PATH=$(wget -O - "$TURL/download/languages/" | grep en-US | grep tar | tr '"' '\n' | grep linux64 | grep -v 'asc$') \
 \
 && echo "$BINARY_PATH" > /tor-browser-version \
 && wget -O /tor.tar.xz "$TURL/$BINARY_PATH" \
 && su - app -c 'tar xvf /tor.tar.xz' \
 \
 && echo 'cd /home/app/tor-browser_en-US/ && cat start-tor-browser.desktop | grep Exec= | sed s/Exec=//g | bash' >> /container/scripts/app
