#!/usr/bin/php -q
<?
/**
*
* @version 1.0.1
*
* @changelog
*	* 2009-02-26 16:34 ver 1.0 to 1.0.1
*	- Check fo --to (-t) parameter replaced from REQUIRED_VAR to more strict REQUIRED_NOT_NULL. So, empty values is allowed!
**/

ini_set('include_path', ini_get('include_path') . PATH_SEPARATOR . dirname(__FILE__));

require_once('System/Console/HuGetopt.php');

include_once('macroses/REQUIRED_VAR.php');
include_once('macroses/REQUIRED_NOT_NULL.php');
include_once('macroses/EMPTY_VAR.php');

include_once('Filesystem/file_base.php');
include_once('RegExp/RegExp_pcre.php');

function usage(){
echo <<<HEREDOC
Usage:

{$GLOBALS['argv'][0]} -w '/what/' -t 'text to' [file1 file2...]

If files not present, STDIN used.

Options:

-a
--after
	Insert argument to AFTER this one. Short form, equals to combination: "--what '/pattern/' --to '$0 add text'"
-w
--what
	What replace. PCRE regular expression. See -p to change to plain text.
-t
--to
	Text to replace. Backreference $0, $1, $2... allowed (while --plain not used).
	So, as no --plain used, and you may use backreference like $1, $2 etc, you shoud escape other appearenc of sign "$" in text --to.

-p
--plain
	Use What replace as plain text instead of regular expression.
-l
--line-after
	Use cooperated with --after. If present - patern --after match to line, and inserting --to after end of line, not in. 
-i
--in-place
	Opt. Replace input file by result. Be careful if results are wrong you may waste all data!!!
-e
--escape
	Opt. Enable interpretation of backslash escapes (\\n, \\r, \\t etc...).

Author: Pavel Alexeev aka Pahan-Hubbitus.
On all suggestions, questions, feature requests, BUG-reports - welcome on http://ru.bir.ru/ ( http://ru.bir.ru/viewtopic.php?f=25&t=652 )

HEREDOC;
}#f usage

//$argv = array(
//  0 => "./replace_in_file.php",
//  1 => "--what",
//  2 => "test",
//  3 => '--to=="ZAQ"=',
//  4 => "-p",
//  5 => '/home/pasha/bin/replace_in_file.test.text'
//);

//var_export($argv);
//$argv = array (
//  0 => 'replace_in_file.php',
//  1 => '-w',
//  2 => '/text/',
//  3 => '-t',
//  4 => 'QAZ',
//  5 => '/home/pasha/bin/replace_in_file.test.text',
//);

//$argv = array (
//  0 => 'replace_in_file.php',
//  1 => '-t',
//  2 => 'text',
//  3 => '-w',
//  4 => '/QAZ/',
//  5 => '/home/pasha/bin/replace_in_file.test.text',
//);

//$argv = array (
//  0 => '/home/pasha/bin/replace_in_file.php',
////  1 => '--after',
////  2 => 'text',
////  3 => '-t',
////  4 => '=\\1=\nQAZ',
//// 5 => '/home/pasha/bin/replace_in_file.test.text'
// 1 => '-ipx'
//);

//$argv = array (
//	0 => '/home/pasha/bin/replace_in_file.php',
// 1 => '--after',
//// 2 => '/test/',
// 2 => 'test',
//// 2 => '/line.*/',
// 3 => '--to=QAZ\n',
// 4 => '-pl',
// 5 => '/home/pasha/bin/replace_in_file.test.text',
//);

//$argv = array(
//  0 => "/home/pasha/bin/replace_in_file",
//  1 => "-i",
//  2 => "/usr/src/redhat/SPECS/kernel.Hu.spec",
//  3 => "--what",
//  4 => "/Patch0(\d+):/",
//  5 => "--to",
//  6 => "Patch$1:",
//);

//$argv = array(
//  0 => "/home/pasha/bin/replace_in_file",
//  1 => "-i",
//  2 => "/usr/src/redhat/SPECS/kernel.Hu.spec",
//  3 => "-pl",
//  4 => "--after",
//  5 => "%define with_bootwrapper %{?_without_bootwrapper: 0} %{!?_without_bootwrapper: 1}",
//  6 => "--to",
//  7 => '
//#+Hu2 Apply Hubbitus config options, if it does not disabled
//%define with_huconfig  %{?_without_huconfig:    0} %{!?_without_huconfig:   1}
//',
//  8 => '--after=#if a rhel kernel, apply the rhel config options
//%if 0%{?rhel}
//  for i in %{all_arch_configs}
//  do
//    mv $i $i.tmp
//    ./merge.pl config-rhel-generic $i.tmp > $i
//    rm $i.tmp
//  done
//  for i in kernel-%{version}-{i586,i686,i686-PAE,x86_64}*.config
//  do
//    echo i is this file  $i
//    mv $i $i.tmp
//    ./merge.pl config-rhel-x86-generic $i.tmp > $i
//    rm $i.tmp
//  done
//%endif',
//  9 => "--to",
//  10 => '
//#+Hu2+15 Apply Hubbitus config options, if it does not disabled.
//# Doing by example of applying rhel config options
//%if %{with_huconfig}
//        for i in %{all_arch_configs}; do
//        mv $i $i.tmp
//        %{SOURCE15} config-hubbitus-generic $i.tmp > $i
//        rm $i.tmp
//        done
//
//        for i in kernel-%{version}-{i586,i686,i686-PAE,x86_64}*.config ; do
//        echo i is this file $i
//        mv $i $i.tmp
//        %{SOURCE15} config-hubbitus-x86-generic $i.tmp > $i
//        rm $i.tmp
//        done
//%endif
//
// '
//);
//$argc = sizeof($argv);
//dump::a($argv);

	if (1 == $argc) exit(usage());

$opts = new HuGetopt(
	array(
		array('a', 'after', ':'),
		array('l', 'line-after'),
		array('w', 'what', ':'),
		array('t', 'to', ':'),
		array('i', 'in-place'),
		array('p', 'plain'),
		array('e', 'escape'),
	)
);

$opts->readPHPArgv()->parseArgs();
$nonopts = $opts->getNonOpts(1);
	try{
	REQUIRED_VAR(EMPTY_VAR($opts->get('what')->Val->{0}, $opts->get('after')->Val->{0}), '--what or --after');
	#REQUIRED_VAR($t = !is_null($opts->get('to')->Val->{0}), '--to');
	REQUIRED_NOT_NULL($opts->get('to')->Val->{0}, '--to');
//-	$inplace	= EMPTY_VAR(@$options[0]['i'], @$options[0]['--in-place'], false);
	}
	catch(VariableRequiredException $vre){
	exit('Missed mandatory parameter: '.$vre->varName()."\n");
	}

	if (!isset($nonopts->{0})) $nonopts->{0} = 'php://stdin';

	if($opts->get('i')->Val->_last_){
		if ($opts->getNonOpts()->length() > 2){//0 - self name
		echo 'Warning! Mix --in-place option with multiple in-files. Use first - "'.$opts->getNonOpts()->{1}.'" to output.'."\n";
		echo 'Wait 3 second to chance of hit Ctrl+C'."\n";
		sleep(3);
		}
	}
	else $outFileName = 'php://stdout';

	if ($opts->get('after')->Val->{0}){
		if ($opts->get('what')->Val->{0}) throw new VariableRangeException('You can not use mix --what and --after option at once!');
	$what	= $opts->get('after')->Val;
	$prefixTo = '$0';
	}
	else{
		if ($opts->get('after')->Val->{0}) throw new VariableRangeException('You can not use mix --what and --after option at once!');
	$what	= $opts->get('what')->Val;
	$prefixTo = '';
	}

	#For string-eval esape characters like \n, \t, \r and other use ->walk
	if ($opts->get('escape')->Val->_last_){
		if ($opts->get('plain')->Val->{0}){//If Palin - add slaches before "$" too.
		$to		= $opts->get('to')->Val->walk(create_function('&$v', 'eval(\'$v = "'.$prefixTo.'\' . addcslashes($v, \'"$\') . \'";\');'));
		}
		else{
		$to		= $opts->get('to')->Val->walk(create_function('&$v', 'eval(\'$v = "'.$prefixTo.'\' . addcslashes($v, \'"\') . \'";\');'));
		}
	}		
	elseif($prefixTo){
	$to		= $opts->get('to')->Val->walk(create_function('&$v', '$v = \''.$prefixTo.'\' . $v;'));
	}
	else{//SpeedUp only. No needed loop if $prefixTo empty!
	$to		= $opts->get('to')->Val;
	}

	if ($opts->get('plain')->Val->{0}) $what->walk(create_function('&$v', '$v = \'/\'.RegExp_pcre::quote($v, \'/\').\'/\';'));

	if ($opts->get('line-after')->Val->_last_){
	$newWhat = array();
		foreach ($what->getArray() as $k => $v){
		$re = new RegExp_pcre($v);
		//[\r\n] instead & because $ not included in pattern in any case!
		$newWhat[$k] = $re->getRegExpDelimiterStart().$re->getRegExpBody().'.*[\r\n]'.$re->getRegExpDelimiterEnd().$re->getRegExpModifiers();
		}
	$what = new HuArray($newWhat);
	}

/////////////////////////

	foreach ($nonopts->getArray() as $file){
		if ($opts->get('i')->Val->_last_) $outFileName = $file;
	$fileCont = new file_base($file);
	$fileCont->loadContent();

	$re = new RegExp_pcre(
		$what->getArray(),
		$fileCont->getBLOB(),
		$to->getArray()
	);

	$outFile = new file_base;
	$outFile->setPath($outFileName)->setContentFromString($re->replace())->writeContents();
	}
?>