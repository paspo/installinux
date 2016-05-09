<?php


class SysInfo extends \Prefab {

  public $kernel = "unknown";
  public $uptime = "unknown";
  public $load = "";
  public $loadPercent = null;
  public $netDevices = array();
  public $scsiDevices = array();
  public $usbDevices = array();
  public $diskDevices = array();
  public $memFree = 0;
  public $memTotal = 0;
  public $memUsed = 0;
  public $memApplication = null;
  public $memBuffer = null;
  public $memCache = null;
  public $swapDevices = array();

  protected function _runCommand($command, $default_value='unknown') {
    $ret = shell_exec($command);
    return is_null($ret) ? $default_value : $ret;
  }

  function __construct() {
    $this->hostname = $this->_runCommand('hostname');
    $this->uptime = $this->_runCommand('uptime');
  }

}
