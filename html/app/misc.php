<?php

class misc {

    function status($f3) {
      $this->sysinfo = \SysInfo::instance();
      $f3->set('hostname',$this->sysinfo->hostname);
      $f3->set('uptime',$this->sysinfo->uptime);
      echo Template::instance()->render('status.html');
    }

    function uptime($f3) {
        $this->sysinfo = \SysInfo::instance();
        $values = array();
        $values['uptime'] = $this->sysinfo->uptime;
        echo json_encode($values);
    }

    function procs($f3) {
        $commands = array(
                'proc_apache2' => 'apache2',
                'proc_dnsmasq' => 'dnsmasq',
                'proc_pure_ftpd' => 'pure-ftpd',
                'proc_rpc_mountd' => 'rpc.mountd',
                'proc_rpc_statd' => 'rpc.statd',
                'proc_rpcbind' => 'rpcbind',
                'proc_squid3' => 'squid3',
                'proc_sshd' => 'sshd',
            );

        $values = array();

        foreach ($commands as $key=>$command) {
            $ret=exec("pidof -s \"$command\"");
            $values[$key]=(int)$ret>0;
        }

        echo json_encode($values);
    }

    function taillog($f3) {
      new Session();
      $handle = fopen('/var/log/squid3/access.log', 'r');
//      $handle = fopen('/var/log/apache2/access.log', 'r');
//      $handle = fopen('data/access.log', 'r');  // TODO: this is a link to the correct file.We really need to use the squid log, so some php.ini tweaking is required
      if ( $f3->exists('SESSION.offset') ) {
        $data = stream_get_contents($handle, -1, $f3->get('SESSION.offset'));
        $data = str_replace(array(
            'TCP_MEM_HIT/200',
            'TCP_REFRESH_UNMODIFIED/304',
            'TCP_MISS/200',
            'TCP_MISS/206',
            'TCP_MISS/301',
            'TCP_MISS/302',
            'TCP_MISS/304'
        ),array(
            '<span class=\'hit\'>TCP_MEM_HIT/200</span>',
            '<span class=\'hit\'>TCP_REFRESH_UNMODIFIED/304</span>',
            '<span class=\'miss\'>TCP_MISS/200</span>',
            '<span class=\'miss\'>TCP_MISS/206</span>',
            '<span class=\'redir\'>TCP_MISS/301</span>',
            '<span class=\'redir\'>TCP_MISS/302</span>',
            '<span class=\'redir\'>TCP_MISS/304</span>'
        ),$data);
        echo nl2br($data);
      }
        fseek($handle, 0, SEEK_END);
        $f3->set('SESSION.offset', ftell($handle));

    }

    function error($f3) {
        $log = new Log('error.log');
        $log->write($f3->get('ERROR.text'));
        foreach ($f3->get('ERROR.trace') as $frame) {
            if (isset($frame['file'])) {
                // Parse each backtrace stack frame
                $line = '';
                $addr = $f3->fixslashes($frame['file']) . ':' . $frame['line'];
                if (isset($frame['class'])) {
                    $line.=$frame['class'] . $frame['type'];
                }
                if (isset($frame['function'])) {
                    $line.=$frame['function'];
                    if (!preg_match('/{.+}/', $frame['function'])) {
                        $line.='(';
                        if (isset($frame['args']) && $frame['args']) {
                            $line.=$f3->csv($frame['args']);
                        }
                        $line.=')';
                    }
                }
                // Write to custom log
                $log->write($addr . ' ' . $line);
            }
        }
        Template::instance()->render('error.html');
    }

}
