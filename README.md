# Reläa

Reläa aspires to share xdrip+ data via Local Broadcast to the Even Realities G1 smartglasses. Forked from fahrplan.

This is WIP, the readme (in main) will be updated when a usable version is ready.


Forked from [Fahrplan](https://github.com/meyskens/fahrplan/tree/main)

"Reläa" is a Sweedish word for electrical relay which is the extent of what I want to accomplish with this garden project. I want an application that can easilly forward glucose data from a users xdrip+ phone to the Even Realities headset so the user can know their glucose at a glance.

While it is meant to offer an "OS" for the Even Realities G1 and will copy some of the original functionality like notifications it is not designed to be a full smartglasses OS.

## Why the G1 specifically?

Simple: they are the only glasses with display that fit my face and are able to ship my prescription. That's it.

## Supported OSes?

- Android (primary development)
- iOS (probably works in simple tasks, notifications and permissions will need work!)
- Linux will not work: experiments have been done with Bluez but BLE notifications are buggy, sorry

## Thanks
Thanks to @emingenc and @NyasakiAT for their work in building the G1 BLE libraries
- https://github.com/emingenc/even_glasses (The most complete library!)
- https://github.com/emingenc/g1_flutter_blue_plus/tree/main (The foundations for the Dart implementation)
- https://github.com/NyasakiAT/G1-Navigate (Further development of the Dart implementation and BMP composing code)

## Copy me!

As mentioned above this is already a forked project. If any of this is useful to you copy it.