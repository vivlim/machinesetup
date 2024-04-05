import { usb, getDeviceList } from 'usb';
import * as path from 'path';
import * as child_process from "child_process";

const knownDevices = [
    {
        label: "launch scrcpy to mirror phone",
        id: {
            idVendor: 6353,
            idProduct: 20199,
        },
        command: "scrcpy --keyboard=uhid --max-size=1024 --max-fps=60 --no-audio --always-on-top"
        /*
scrcpy --keyboard=uhid --max-size=1024 --max-fps=60 --no-audio --always-on-top #--audio-codec=flac --audio-codec-options=flac-compression-level=2 --audio-buffer=200
#scrcpy --keyboard=uhid --max-size=1024 --max-fps=60 --audio-codec=flac --audio-codec-options=flac-compression-level=2 --audio-buffer=200
        */
    }
]

function launchIfDevicePresent(seenDeviceList) {
    for (const sd of seenDeviceList) {
        for (const kd of knownDevices) {
            if (sd.deviceDescriptor.idVendor === kd.id.idVendor && sd.deviceDescriptor.idProduct === kd.id.idProduct) {
                console.log(`${kd.label}: Matched device ${sd.deviceDescriptor.idVendor}:${sd.deviceDescriptor.idProduct}, running command ${kd.command}`);
                child_process.exec(kd.command);
            }

        }
    }

}

usb.on("attach", function(d){
    console.log(`attached: ${JSON.stringify(d)}`)
    launchIfDevicePresent([d])

})


const devices = getDeviceList();
launchIfDevicePresent(devices)