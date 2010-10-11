#!/usr/bin/php -q
<?
/**
* HuRegRep. Utility to make regular replacemnts in files.
*
* @version 1.1
* @package HuRegRep
* @author Pahan-Hubbitus (Pavel Alexeev) <Pahan [at] Hubbitus [ dot. ] info>
* @copyright Copyright (c) 2010, Pahan-Hubbitus (Pavel Alexeev)
* @license GPLv2+
*
* @changelog
*	* 2009-02-26 16:34 ver 1.0 to 1.0.1
*	- Check fo --to (-t) parameter replaced from REQUIRED_VAR to more strict REQUIRED_NOT_NULL. So, empty values is allowed!
*
*	* 2010-09-28 22:46 ver 1.0.1 to 1.1
*	- Add -c (--comment) option support.
**/

ini_set('include_path', ini_get('include_path') . PATH_SEPARATOR . dirname(__FILE__));

include_once('autoload.php');

include_once('macroses/REQUIRED_VAR.php');
include_once('macroses/REQUIRED_NOT_NULL.php');
include_once('macroses/EMPTY_VAR.php');


/**
* Prints usage description.
*
* @return nothing
**/
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

-c
--comment
	Opt. Just for comments instruction because shell does not accept it inside one comment. Just ignored.

Author: Pavel Alexeev aka Pahan-Hubbitus.
On all suggestions, questions, feature requests, BUG-reports - welcome on http://ru.bir.ru/ ( http://ru.bir.ru/viewtopic.php?f=25&t=652 )

HEREDOC;
}#f usage

	/** Start options setup and parsing **/
	if (1 == $argc) exit(usage());

$opts = new HuGetopt( # Array of recognized options
	array(
		array('a', 'after', ':'),
		array('l', 'line-after'),
		array('w', 'what', ':'),
		array('t', 'to', ':'),
		array('i', 'in-place'),
		array('p', 'plain'),
		array('e', 'escape'),
		array('c', 'comment', ':'),
	)
);

$opts->readPHPArgv()->parseArgs();
$nonopts = $opts->getNonOpts(1);
	try{
	REQUIRED_VAR(EMPTY_VAR($opts->get('what')->Val->{0}, $opts->get('after')->Val->{0}), '--what or --after');
	REQUIRED_NOT_NULL($opts->get('to')->Val->{0}, '--to');
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

	/**
	* Main loop of processing
	**/
	foreach ($nonopts->getArray() as $file){
		if ($opts->get('i')->Val->_last_) $outFileName = $file;
	$fileCont = new file_inmem($file);
	$fileCont->loadContent();

	$re = new RegExp_pcre(
		$what->getArray(),
		$fileCont->getBLOB(),
		$to->getArray()
	);

	$outFile = new file_inmem;
	$outFile->setPath($outFileName)->setContentFromString($re->replace())->writeContent();
	}
?>