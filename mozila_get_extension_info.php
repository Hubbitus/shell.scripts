#!/usr/bin/php -q
<?
include_once('Debug/debug.php');
include_once('Vars/Consts/consts.php');

	if (empty($argv[1])){
	exit ("Необходимо имя файла (URL) для обработки!\n");
	}

$iFILE = $argv[1];

#$iFILE='test.htm';
#$iFILE='info.first.htm.ORIG';
#$oFILE='test.phpres.htm';

$t = new tidy($iFILE, array("wrap" => 0), 'utf8');
$t->cleanRepair();

#Search: <div class="addon-feature-text">

$tBodyNode = $t->body();
//dump::c($tBodyNode);
//c_dump($tBodyNode->child);
//c_dump(consts::get_regexp('tidy', '#TIDY_NODETYPE#'));
//c_dump(consts::get_regexp('tidy', '#TIDY_TAG#'));
//c_dump(consts::get('TIDY_TAG_DIV'));	#30
//exit();

	/**
	* As prototype gets get_nodes2 from comments: http://ru2.php.net/manual/ru/function.tidy-node-get-nodes.php
	* Modified.
	* array $attributes - array of 'Key' => value attribitus, which must be in tag
	**/
	function tidy_get_nodes_recursive($node, $type, array $attributes, &$result){
		if($node != null){
			if (
				@$node->id == $type
				 and ! empty ($attributes)
				 and count ($attributes) == count (array_intersect_assoc ($attributes, (array)$node->attribute))
			 ) $result[] = $node;

			if ($node->child != null){
				foreach($node->child as $child){
				tidy_get_nodes_recursive($child, $type, $attributes, $result);
				}
			}
		}
	}

//get_nodes_recursive($tBodyNode, TIDY_TAG_DIV, array('name' => 'test'), $divs);
#Предполагаем что это addons.mozilla.org
//tidy_get_nodes_recursive($tBodyNode, TIDY_TAG_DIV, array('class' => 'addon-feature-text'), $divs);
tidy_get_nodes_recursive($tBodyNode, TIDY_TAG_P, array('class' => 'desc'), $divs);

//c_dump($divs);
#>0 if found
//c_dump(count($divs));
//c_dump($divs[0]->value);

	if (empty($divs)){//Пердположим тогда что forum.mozilla-russia.org
	tidy_get_nodes_recursive($tBodyNode, TIDY_TAG_DIV, array('class' => 'postmsg'), $divs);
	}

	if (! empty($divs) ){#Found
	echo(
		preg_replace(
		array('#<br.*?>#i', '#<.*?>#')
		,array('', '')
		,$divs[0]->value
		)
	);
	}
	else{
	exit('Упппс. Требуемого блока не найдено!');
	}

//$img_nodes = $tBodyNode->getNodes(TIDY_TAG_DIV);

/*
	if ($t->errorBuffer) {
	echo "The following errors were detected:\n";
	echo $t->errorBuffer;
	}
*/
?>
