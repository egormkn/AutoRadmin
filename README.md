# AutoRadmin

AutoRadmin — cкрипт AutoIt для автоматизации подключения в Radmin Viewer (автоматический ввод и сохранение пароля в Radmin).

## Использование

1. Загрузите [последнюю версию AutoRadmin](https://github.com/egormkn/AutoRadmin/releases/download/latest/AutoRadmin.exe) и сохраните в любую удобную папку (например, на Рабочий стол).
2. Запустите AutoRadmin.exe. При первом запуске будет создан файл `config.ini`.
3. Отредактируйте файл `config.ini`, указав аргументы запуска Radmin, имя пользователя и пароль для подключения.
4. При следующем запуске AutoRadmin выполнит подключение в соответствии с заданными настройками.

### Конфигурация по умолчанию

```
ARGS=/connect:desktop.example.com:1234 /through:server.example.com:5678 /fullstretch
USER=Alice
CONNECTPASS=12345678
THROUGHPASS=87654321
```
