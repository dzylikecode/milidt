# file struct
- main.dart     ---> entry 
- app.dart      ---> app widget implements
- controller.dart ---> app state management
- pages/  ---> page widgets
  - xxx/  ---> page implementation
    - page.dart ---> page layout
    - controller.dart ---> page state management
    - binding.dart ---> getx injection 
  - pages.dart ---> export all pages
- widgets/
  - xxxx/
  - xxxxx.dart
- services/  ---> app state, api
  - xxx.dart


## 命名习惯

- pages 中的动作均是button之类的，实际的动作在controller当中