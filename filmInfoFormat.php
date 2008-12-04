#!/usr/bin/php
<?
include_once('Debug/debug.php');
include_once('Settings/settings.php');
include_once('template/template_class_2.1.php');

class filmInfo_settings extends settings{
protected $__SETS = array(
	'Items'	=> array(	#То, что необходимо заполнить
		'Year'		=> 'год (?:выпуска|выхода)',
		'Country'		=> '(?:страна|производство)',
		'Studio'		=> 'Студия',
		'Type'		=> 'жанр',
		'Duration'	=> 'Продолжительность',
		'Translation'	=> 'Перевод',
		'Regisser'	=> 'Режиссер',
		'Scenarist'	=> 'Сценарий',
		'Producer'	=> 'Продюсер',
		'Operator'	=> 'Оператор',
		'Kompositor'	=> 'Композитор',
		'InRoles'		=> 'В(?: главных)? ролях',
		'Description'	=> '(?:Описание|О фильме)',

		'Premies'		=> 'Премии и награды',
		'Quality'		=> 'Качество',
		'OtherNames'	=> 'Другие названия фильма',

		'Notes'		=> 'Примечание'
		),
	'TEMPLATE'		=> '/mnt/maxtor/films_from_net/template.info.htm'
	);
}#c filmInfo_settings

class filmInfoItems extends settings{
protected $__SETS = array(
		'Name'		=> '',
		'Year'		=> '',
		'Country'		=> '',
		'Type'		=> '',
		'Duration'	=> '',
		'Translation'	=> '',
		'Regisser'	=> '',
		'Scenarist'	=> '',
		'InRoles'		=> '',
		'Description'	=> '',

		'Premies'		=> '',
		'Quality'		=> '',

		'AUDIO'		=> '',
		'VIDEO'		=> ''
	);
}

#$argv[1] - Имя файла-описания
#$argv[2] - Имя файла-видео, чтобы взять параметры с него

class filmInfo extends get_settings{
const TagsRegs = '(?:\s*<[^<>]+>\s*)*';

//protected $_sets = null;
private /* filmInfoItems */ $filmInfo = null;
protected $argv;

	function __construct($argv, $sets = null){
	$this->argv = $argv;

	$this->filmInfo = new filmInfoItems;

		if (is_array($sets)) $this->_sets = new filmInfo_settings((array)$sets);
		elseif($sets) $this->_sets = $sets;
		else $this->_sets = new filmInfo_settings();#Дефолт

	#Приведем все к Юникоду!
	setlocale(LC_ALL, 'ru_RU.UTF-8');
	exec('enconv '.escapeshellarg($this->argv[1]).' -x UTF-8 2>&1');

	$this->getFileContent($this->argv[1]);
	$this->parseAll();
	}#c

	function getFileContent ($filename){
	$this->filmInfo->setSetting('rawString', file_get_contents($filename));
	}#m getFileContent

	function parseAll(){
	$this->filmInfo->setSetting('Name', $this->parseFilmName());
		foreach ($this->settings->Items as $ItemName => $ItemReg){
		$this->filmInfo->setSetting($ItemName, $this->parseItem($ItemName, $ItemReg));
		}
	
	$this->filmInfo->setSetting('AUDIO', $this->getParseParams('AUDIO'));
	$this->filmInfo->setSetting('VIDEO', $this->getParseParams('VIDEO'));
	}#m parseAll

	function parseFilmName(){
	$Name = $this->parseItem('Name', 'название').NON_EMPTY_STR($this->parseItem('Name', 'Оригинальное название'), ' / ');
		if (!$Name){
		preg_match('#<div class="post_body">'.self::TagsRegs.'(.+?)</#uims', $this->filmInfo->rawString, $Name);
		$this->debugInfo('Name', '#<div class="post_body">'.self::TagsRegs.'(.+?)</#uims', $Name);
		return @$Name[1];
		}
		else return $Name;
	}#m parseFilmName()

	function parseItem($name, $reg){
	preg_match('#'.$reg.self::TagsRegs.':'.self::TagsRegs.'(.+?)<#uims', $this->filmInfo->rawString, $Item);
//	$this->debugInfo($name, $reg, $Item);
	$this->debugInfo($name, '#'.$reg.self::TagsRegs.':'.self::TagsRegs.'(.+?)(?>\s*)<#uims', $Item);
	return trim(@$Item[1]);
	}#m parseItem

	function getParseParams($name){
	$str = exec('/home/pasha/bin/aviInfo.'.strtolower($name).' '.escapeshellarg($this->argv[2]).' 2>&1');
	preg_match('#'.strtoupper($name).':\s+'.'(.+)$#uims', $str, $Item);
	$this->debugInfo($name, '#'.strtoupper($name).':\s+'.'(.+)$#uims', $Item);
	return str_replace('  ', ' ', @$Item[1]);
	}#m getParseParams

	function writeFile($filename, $format = null){
	$tmpl = new template($this->settings->TEMPLATE);

	$tmpl->assign('Name', $this->filmInfo->Name);
	$tmpl->assign('AUDIO', $this->filmInfo->AUDIO);
	$tmpl->assign('VIDEO', $this->filmInfo->VIDEO);
	
		foreach ($this->settings->Items as $ItemName => $ItemReg){
		$tmpl->assign($ItemName, $this->filmInfo->$ItemName);
		}
	$tmpl->parse(false);
	file_put_contents($filename, $tmpl->content_file);
	}

##################
	protected function debugInfo($name, $reg, &$res){
		if(!@$res[1]){
		echo $name . ' не найден'."\n";
		dump::a($reg);
		dump::a($res);
		}
	}
}#c filmInfo


	if (@$argv[1] and @$argv[2]){
	$film = new filmInfo($argv);
#	rename($argv[1], $argv[1].'.bak');
#	$argv[1] = $argv[1].'.bak';
	$film->writeFile('info.htm');
	}
//	else $cont = file_get_contents('php://stdin');
	else exit ('Необходимо указать файл для обработки и файл-видео!'."\n");
?>