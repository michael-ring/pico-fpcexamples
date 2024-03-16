program esp_worldtimeapi;
{
  This file is part of pico-fpcsamples
  Copyright (c) 2021 -  Michael Ring

  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}

{$MODE OBJFPC}
{$H+}
{$MEMORY 10000,10000}

uses
  pico_c,
  pico_gpio_c,
  pico_uart_c,
  esp_at_c;
const
  BAUD_RATE=115200;
var
  esp : Tesp_at;
  response : TResponse;
begin
  //gpio_set_function(TPicoPin.UART_TX, TGPIO_Function.GPIO_FUNC_UART);
  //gpio_set_function(TPicoPin.UART_RX, TGPIO_Function.GPIO_FUNC_UART);
  //uart_init(uart, BAUD_RATE);
  gpio_set_function(TPicoPin.GP16, TGPIO_Function.GPIO_FUNC_UART);
  gpio_set_function(TPicoPin.GP17, TGPIO_Function.GPIO_FUNC_UART);
  uart_init(uart0, BAUD_RATE);

  // {$define SSID := 'name of access point'}
  // {$define PASSWORD := 'password for AP'}
  {$MACRO ON}
  {$include credentials.inc}
  esp.init(uart,TPicoPin.GP2,SSID,PASSWORD);
  response := esp.get('https://worldtimeapi.org/api/ip',[]);
end.
