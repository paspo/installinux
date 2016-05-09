<?php

class system {

    function show($f3) {
      echo Template::instance()->render('system.html');
    }

    function do_reboot($f3) {
        exec("sudo /sbin/reboot");
        // TODO: add status message
        echo Template::instance()->render('system.html');
    }

    function do_shutdown($f3) {
        exec("sudo /sbin/poweroff");
        // TODO: add status message
        echo Template::instance()->render('system.html');
    }

}
