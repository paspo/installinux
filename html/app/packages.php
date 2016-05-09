<?php

class packages {

    function show($f3) {
        exec("sudo /usr/share/installinux/html/scripts/list_available_packages.sh --json", $json_array, $ret);
        $json=json_decode(implode($json_array));
	$f3->set("repositories", $json->repositories);
#        var_dump($json);
#        die();
        echo Template::instance()->render('packages.html');
    }

    
}
