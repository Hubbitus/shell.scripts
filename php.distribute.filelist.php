#!/usr/bin/php
<?
	if (isset($argv[1])) $dir = $argv[1];
	else{
	echo 'Warning. Directory not provided. Using "./"'."\n";
	$dir = './';
	}

include_once('RegExp/RegExp_pcre.php');
include_once('Filesystem/file_inmem.php');
include_once('Vars/HuArray.php');

$files = array();

	//Example from user comments
	foreach (
		new RecursiveIteratorIterator(
			new RecursiveDirectoryIterator(
				$dir,
				RecursiveDirectoryIterator::KEY_AS_PATHNAME
			),
			RecursiveIteratorIterator::CHILD_FIRST
		) as $file => $info){

		if (!$info->isDir()){
		echo "Process $file\n";
		$f = new file_inmem($file);
		$f->loadContent();
		$re = new RegExp_pcre(
			'/(?:include|require|tryIncludeByClassName)(?:_once)?[\s\(]*([\'"])(.*?)\1/i',
			$f->getBLOB()
		);
		$re->doMatchAll( PREG_PATTERN_ORDER );
		$inc = HuArray::create($re->getMatches());
			if ($inc->{2}){
//			dump::a($inc->{2});
//			$files = array_merge($files, $inc->{2});
				foreach ($inc->{2} as $i){
					if (!in_array($i, $files)){
					$files[] = $i;
					echo "[$i] - ". (file_exists($dir.$i) ? "Ok" : "Not Found!")."\n";
					}
				}
			}
		}
	}

//dump::a($files);
//dump::a(array_unique($files));
?>