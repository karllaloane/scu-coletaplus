![Captura de tela 2024-12-19 141240](https://github.com/user-attachments/assets/12b87891-5485-4ef9-8b68-fae9c7b5c162)


# Coleta+ - Aplicativo para otimização de rotas de coleta de resíduos

Este projeto faz parte do sistema de coleta de resíduos em cidades inteligentes, com funcionalidades como monitoramento em tempo real, rotas otimizadas baseadas em volume de lixo e geolocalização, além de geração de relatórios de eficiência.

## Funcionalidades

- Rotas otimizadas: busca e exibição de rotas de coleta com base no volume de resíduos e localização geográfica do dispositivo.
- Monitoramento em tempo real: atualizações em tempo real das condições das lixeiras e rotas.

🎥 [Clique aqui para o vídeo demonstrativo do aplicativo em um smartphone](https://drive.google.com/file/d/1XO40YPYeqsmvCMXveAGvS3Z2PmbvX16R/view?usp=sharing)

🎥 [Clique aqui para o vídeo demonstrativo do aplicativo em um tablet](https://drive.google.com/file/d/1XwZ50HXxMYI7Eonu7OkgCxVPZUt1voKm/view?usp=sharing)

🎥 [Clique aqui para o vídeo demonstrativo da continuidade do aplicativo em diferentes dispositivos](https://drive.google.com/file/d/13OzFri5UUT7kV6CBx0GSj4GkuT94U-e2/view?usp=sharing)

📱 [Baixe aqui o APK para instalação no Android](https://drive.google.com/file/d/1uK5CldALRnEKQJDRb8PIeH_W0GUgMG3S/view?usp=sharing)
_(Verifique com os integrantes do projeto sobre a disponibilidade do servidor)._

## Pré-requisitos

### Clonar o repositório

Clone este repositório com o comando:

```
git clone https://github.com/karllaloane/scu-coletaplus
```

### Servidor Backend
Para que o aplicativo funcione corretamente, é necessário garantir que o servidor backend do sistema esteja em execução. O servidor backend pode ser acessado pelo endereço padrão configurado no aplicativo. Caso prefira rodar o backend localmente:

1. Clone o repositório do backend: [sicoin-backend](https://github.com/JohnTFM/sicoin-backend)
2. Configure e execute o backend seguindo as instruções disponíveis no repositório.
3. Altere a URL das chamadas para a API no arquivo `lib/backend/schemas/utils/config.dart`, inserindo o endereço de IP da máquina e a porta 8088.

## Configuração do Ambiente de Desenvolvimento

Certifique-se de ter as seguintes ferramentas e dependências configuradas:

### Ambiente Flutter

- **SDK Flutter**: O projeto requer Flutter com suporte para o Dart `SDK >=3.0.0 <4.0.0`. Instale o Flutter seguindo a documentação oficial: [windows](https://docs.flutter.dev/get-started/install/windows/mobile) ou linux [linux](https://docs.flutter.dev/get-started/install/linux/android).

- **Android Studio**: Recomendado para configuração e execução em dispositivos físicos ou emuladores.
  - Inclua o SDK do Android.
  - Configure ao menos um emulador Android.
  - Para mais informações: (Instalar o Android Studio)[https://developer.android.com/studio/install?hl=pt-br]
 
- Outras opções de IDE:
  - Visual Studio Code: Instale as extensões Flutter e Dart.

## Dependências do Projeto

Após clonar o repositório do aplicativo, instale as dependências executando os seguintes comandos na raiz do projeto:

```
flutter clean
```

```
flutter pub get
```

### Executando o Aplicativo

Observação: Certifique-se de que o servidor backend está em execução antes de iniciar o aplicativo.

**Em Dispositivos Físicos**
- Conecte o dispositivo ao computador e ative a depuração USB ou depuração WiFi.
- Execute o aplicativo no dispositivo:

```
flutter run
```

**Em Emuladores Android**
- Inicie um emulador pelo Android Studio.
- Execute o comando e aguarde a instalação.:

```
flutter run
```

## Observações importantes

1. A URL do backend já está configurada para o servidor padrão em produção. Certifique-se de que ele está ativo.
2. Caso deseje utilizar um backend local, ajuste a URL no arquivo config.dart e reinicie o aplicativo.
3. Consulte os logs em tempo real no console da IDE para verificar mensagens de erro ou informações.


## Outros repositórios importantes para o projeto:

📂 Repositório backend do projeto: [sicoin-backend](https://github.com/JohnTFM/sicoin-backend)

📂 Repositório para documentação, diagramas e arquitetura do projeto: [PadraoArqui-SCU](https://github.com/karllaloane/PadraoArqui-SCU)

📂 Repositório do portal web do projeto, para relatórios e dashboard: [sicoin-frontend](https://github.com/JvRosa/sicoin-frontend)

