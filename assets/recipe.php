<?php

$jsonFlags = JSON_HEX_TAG | JSON_HEX_AMP | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE;

function var_error_log( $object = null ){
	ob_start();
	var_dump( $object );
	$contents = ob_get_contents();
	ob_end_clean();
	error_log( trim( $contents ) );
}

$doc = json_decode( file_get_contents('php://stdin') );

$format = '';
$action = function( $t, $c, $format, $meta, &$userData ) {
	if( $t === 'Header' && $c[0] === 1 )
	{
		$userData['currentClasses'] = $c[1][1];
	}
	
	if( $t === 'BulletList' && in_array( 'ingredients', $userData['currentClasses'] ) )
	{
		$rows = [];
		
		foreach( $c as $item_blocks )
		{
			foreach( $item_blocks as $item_block )
			{
				list( $quantity, $ingredient ) = unitise( $item_block );
				$rows[] = [ [ $quantity ], [ $ingredient ] ];
			}
		}
		
		return Table(
			[ '', '' ],
			$rows
		);
	}
};

$meta = isset( $doc->meta )
	? $doc->meta
	: ( isset( $doc[0] ) && isset( $doc[0]->unMeta ) ? $doc[0]->unMeta : null );

$altered = walk(
	$doc,
	$action,
	$format,
	$meta,
	[ 'currentClasses' => [] ]
);

$json = json_encode( $altered, $jsonFlags );
	
echo $json;

function unitise( $block )
{
	$content = $block->c;
	$quantity = clone( $block );
	
	if( count( $content ) > 2 && $content[0]->t === 'Emph' && $content[1]->t === 'Space' )
	{
		$quantity->c = $content[0]->c;
		$block->c = array_slice( $content, 2 );
	}
	else
	{
		$quantity->c = [];
	}
	
	return [ $quantity, $block ];
}

function TableAlign( $type = 'AlignDefault' )
{
	return (object)[ 't' => $type ];
}

function Str( $string )
{
	return (object)[ 't' => 'Str', 'c' => $string ];
}

function Plain( array $blocks )
{
	return (object)[ 't' => 'Plain', 'c' => $blocks ];
}

function Table( $headers, $rows )
{
	$cols = count( $headers );
	$aligns = array_fill( 0, $cols, TableAlign() );
	$widths = array_fill( 0, $cols, 0 );
	$headers = array_map( function( $header ) {
		return [ Plain( [ Str( $header ) ] ) ];
	}, $headers );
	
	$c = [
		[], # caption
		$aligns,
		$widths,
		$headers,
		$rows
	];
	
	return (object)[
		't' => 'Table',
		'c' => $c
	];
}

function walk( $x, $action, $format, $meta, $userData )
{
	if( is_array( $x ) )
	{
		$array = array();
		foreach( $x as $item )
		{
			if( is_object( $item ) && isset( $item->t ) && isset( $item->c ) )
			{
				$res = $action( $item->t, $item->c, $format, $meta, $userData );
				if( is_null( $res ) )
				{
					$array[] = walk( $item, $action, $format, $meta, $userData );
				}
				elseif( is_array( $res ) )
				{
					foreach( $res as $z )
					{
						$array[] = walk( $z, $action, $format, $meta, $userData );
					}
				}
				elseif( is_object( $res ) )
				{
					$array[] = walk( $res, $action, $format, $meta, $userData );
				}
				else
				{
					$obj = clone $item;
					$obj->c = "$res";
					$array[] = $obj;
				}
			}
			else
			{
				$array[] = walk( $item, $action, $format, $meta, $userData );
			}
		}

		return $array;
	}
	elseif( is_object( $x ) )
	{
		$obj = clone $x;
		foreach( get_object_vars( $x ) as $k => $v )
		{
			$obj->{ $k } = walk( $v, $action, $format, $meta, $userData );
		}

		return $obj;
	}
	else
	{
		return $x;
	}
}
