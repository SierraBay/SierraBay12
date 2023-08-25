# Установка SierraBay
### Скачивание кода

Самый простой способ получить код - использовать GitHub функцию скачивания `.zip`.

Нажми [сюда](https://github.com/SierraBay/SierraBay12/archive/dev-sierra.zip) чтобы получить последнюю версию кода в виде .zip файла, а затем разархивируй его куда захочешь.

Более сложный в скачивании, но более простой в обновлении метод - использование git. Тебе нужно скачать git или клиент [отсюда](http://git-scm.com/). Когда он установится, нажми правой кнопкой мыши в любой папке правую кнопку мыши и выбери "Git Bash". Когда окно откроется, пиши в него:

```sh
git clone https://github.com/SierraBay/SierraBay12.git
```

(Подсказка: чтобы вставить в git bash можно нажать ПКМ по окну, или использовать <kbd>Ctrl</kbd>+<kbd>Insert</kbd>)

Загрузка займет некоторое время, но обновлять билд будет проще.

---

### Установка

Первая установка должна быть довольно простой. Во-первых, вам понадобится установить BYOND. Его можно скачать [здесь](http://www.byond.com/).

Ты скачал только исходный код, поэтому его нужно скомпилировать. Открой `baystation12.dme` двойным кликом, слева сверху выбери вкладку `Build` и там нажми `Compile`. Не пугайся того что почти ничего в консоли долго не происходит, просто жди, это нормально. Это займёт время, но по итогу внизу ты должен увидеть такое сообщение:
```
saving baystation12.dmb (DEBUG mode)

baystation12.dmb - 0 errors, 0 warnings
```

Если ты видишь какие-то ошибки или предупреждения - что-то однозанчно пошло не по плану. Скорее всего либо повреждена загрузка, либо файлы извлечены неправильно, либо мы допустили ошибку в коде. Спросить можно в дискорде, указанном в [`README`](/README.md)

---

### Конфигурация

Copy the contents of the `/config/examples` folder into `/config`. You will now work with everthing contained within `/config`.

Edit `config.txt` to set the probabilities for different gamemodes in Secret and to set your server location so that all your players don't get disconnected at the end of each round.  It's recommended you don't turn on the gamemodes with probability 0, as they have various issues and aren't currently being tested, they may have unknown and bizarre bugs.

Edit `admins.txt` to remove the default admins and add your own.  "Game Master" is the highest level of access, and the other recommended admin levels for now are "Game Admin" and "Moderator".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly capitalised.  There are a bunch more admin ranks, but these two should be enough for most servers, assuming you have trustworthy admins.

To start the server, run Dream Daemon and enter the path to your compiled `baystation12.dmb` file.  Make sure to set the port to the one you  specified in the `config.txt`, and set the Security box to 'Trusted' so you don't have to confirm access to every single configuration and storage file for the server.  Then press GO and the server should start up and be ready to join.

---

### WEBHOOKS

If you wish to use Discord webhooks, which are a way of passing information from the server to a Discord channel, you will need to copy `webhooks.json` into `config/` from `config/example/` and add definitions pointing the desired event at the desired [Discord webhook URL](https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks). Valid webhook IDs as of time of writing are as follows:
- webhook_roundend: The round has ended. Will include the mode name and summarize survivors and ghosts.
- webhook_roundstart: The master controller has finished initializing and the round will begin soon.
- webhook_submap_loaded: A submap has been loaded and placed, and is available for people to join. Includes the name of the submap.
- webhook_submap_vox: The vox submap specifically has been loaded and placed. This is distinct for the purposes of tagging vox players with a @mention.
- webhook_submap_skrell: The Skrell submap specifically has been loaded and placed. This is distinct for the purposes of tagging Skrell players with a @mention.
- webhook_custom_event: The custom event text for the round has been set or changed.

Each definition can optionally include an array of roles to mention when the webhook is called. Roles must be provided using the role ID (ex. `<@&555231866735689749>`), which can be obtained by writing `\@somerole` into the chat, in order for pinging to work correctly.

Webhooks additionally require a HTTP POST library called [byhttp](https://github.com/Lohikar/byhttp). The compiled lib, `byhttp.dll` on Windows or `libbyhttp.so` on Linux, must be placed in the lib directory by default in order for webhooks to function. The DLL location can be customized by supplying `WINDOWS_HTTP_POST_DLL_LOCATION` `UNIX_HTTP_POST_DLL_LOCATION`, or `HTTP_POST_DLL_LOCATION` as preprocessor macros containing the desired path.

---

### UPDATING

To update an existing installation, first back up your `/config` and `/data` folders
as these store your server configuration, player preferences and banlist.

If you used the zip method, you'll need to download the zip file again and unzip it somewhere else, and then copy the `/config` and `/data` folders over.

If you used the git method, you simply need to type this in to git bash:

    git pull

When this completes, copy over your `/data` and `/config` folders again, just in case.

When you have done this, you'll need to recompile the code, but then it should work fine.

---

### SQL Setup

The SQL backend for the `/library/stats` and bans requires a MySQL server.  Your server details go in `/config/dbconfig.txt`.

For initial setup and migrations refer to `/sql/README.md`
