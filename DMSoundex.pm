package DMSoundex;
use Exporter qw(import);
use strict;
use utf8;
use Data::Dumper;
use Encode; 
our @EXPORT_OK = qw(code_word get_matcher);
 
sub _translit_table {
    my $beginning = {
	0 => [
	    "ai","aj","ay","au","a","ei","ej","ey","e","i","oi","oj","oy",
	    "o","ui","uj","uy","u","ue",
	    "ай","ау","а","ей","е","и","ой","о","уй","у","уе","ы"
	],
	1 => [
	    "eu","ia","y","io","yu","ya","yo","iu","io",
            "еу ","иа","й","я","ю","э"
	],
	2 => [
	    "schtsch","schtsh","schtch","scht","schd","sht","schd",
	    "stch","stsch","sc","strz","strs","stsh",
	    "st","szcz","szcs","szt","sht","szd","sd","zdz","zdzh",
	    "zhdzh","zd","zhd",
	    "шщ","счш","сч","шт","шд","щт","щд","стч","стш","сц","стрз",
	    "стрс","стш","ст","сд","здз","здж","ждж","зд","жд"
	],
	3 => [
	    "d","dt","th","t",
	    "д","дт","т"
	],
	4 => [
	    "cz","cs","csz","czs","drs","drz","ds","dsh","dsz","dz","dzh",
	    "dzs","sch","sh","sz","s"," tch","ttch","ttsch","trz","trs",
	    "ts","tz","tts","ttsz","tc","tsz","zh","zs","zsch","zsh","z","j",
	    "ц","ч","дрс","дрз","дс","дш","дщ","дж","ж","з"
	],
	5 => [
	    "chs","g","h","ks","kh","k","q","x",
	    "х","г","к","кс"
	],
	6 => [
	    "m","n",
	    "м","н"
	],
	7 => [
	    "pf","ph","fb","p","f","b","v","w",
	    "ф","фб","б","в","п"
	],
	8 => [
	    "l","л"
	],
	9 => [
	    "r","р"
	]
	
    };

    my $before_vowel = {
	1 => [
	    "ai","aj","ay","ei","ej","ey","oj","oy","oi","ui","uj","uy",
	    "ай","ей","ой","уй","я","ю"
	],
	3 => [
	    "d","dt","th","t",
	    "д","дт","т"
	],
	4 => [
	    "cz","cs","csz","czs","drz","drs","ds","dsh","dsz","dz",
	    "dzh","dzs","schtsch","schtsh","schtch","sch",
	    "shtch","shch","shtsh","sh","stch","stsch","sc","strz","strs",
	    "stsh","sz","s","tch","sd","ttch","ttsch","trz","trs","tsch",
	    "tsh","tc","ts","tz","j",
	    "ц","ч","шт","щт","стж","тч","сд","тш","тщ","тс","тц",
	    "ж","з","зд","здз","дж"
        ],
	5 => [
	    "g","h","kh","k","q",
            "г","х","к"
	],
	6 => [
	    "m","n",
	    "м","н"
	],
	7 => [
	    "au","b","fb","f","p","ph","pf","v","w",
	    "ав","ау","фб","ф","п","пф","в","у","б"
	],
	8 => [
	    "l","л"
	],
	9 => [
	    "r","р"
	],
	43 => [
	    "sht","scht","schd","st","szt","shd","szd","sd","zd","zhd",
	    "шт","счт","чт","ст","шд","сд","зд","жд"
	],
	54 => [
	    "chs","ks","x",
	    "чс","кс"
	],
	66 => [
	    "mn","nm",
	    "мн","нм"
	],
	nc => [
	    "a","e","ia","i","o","u","ue","y",
            "а","е","иа","и","о","у","уе","уй","й"
	]
    };

    my $generic = {
	1 => ["я","ю","ё"],
        3 => [
	    "d","dt","th","t",
	    "д","дт","т"
	],
	4 => [
	    "cz","cs","csz","czs","drz","rsh","drs","dz","dsh","dsz",
	    "dzh","dzs","schtsch","schtsh","schtch",
	    "sch","shtch","shch","shtsh","stch","shch","sh","stch","sch",
	    "sc","strz","strs","sd","shd","s","tch","ch",
	    "trz","trs","tsh","tsch","ttch","ttsh","tc","ts","zdz","tz",
	    "zdzh","zhdzh","zh","z","j",
	    "ч","чс","дрз","дж","рщ","рш","дщ","дш","шщ","щ","ш",
	    "шч","сч","стж","стр","стрс","сд","шд","с","тч","тж","тз",
	    "тс","тш","тч","ттч","ттс","тц","здз","здж","ждж","ж","з","ц","тц"
	],
	5 => [
	    "g","kh","k","q",
            "г","к","х"
	],
	6 => [
	    "m","n",
	    "м","н"
	],
	7 => [
	    "b","fb","f","p","pf","ph","v","w",
	    "б","фб","ф","п","пф","в"
	],
	8 => [
	    "l","л"
	],
	9 => [
	    "r","р"
	],
	43 => [
	    "sht","scht","schd","st","szt","shd","szd","sd","zd","zhd",
	    "шт","чт","щт","ст","шд","сд","жд","жт","зд","зт"
	],
	54 => [
	    "chs","ks","x",
	    "чс","кс"
	],
        66 => [
	    "mn","nm",
	    "мн","нм"
	],
	nc => [
	    "ai","aj","ay","au","a","ei","ej","ey","eu","e","h","ia","ie",
	    "io","iu","i","oi","oj","oy","o","ui","uj","uy","u","ue","y",
            "ай","ау","а","ей","еу","е","х","иа","ио","иу","и","ой","о",
	    "уй","у","уе","й","я","ю","э","ъ","ь","ы","ё"
	]
    };
    return {beginning => $beginning, vowel => $before_vowel, generic => $generic}
}

sub _vowels {
    ["a","o","u","i","e","y","а","е","и","о","y","э","ю","я","ё"]
}

sub _make_beg_exprs {
    my $type = shift;
    my $ttable = _translit_table;
    my $begs = {};
    for my $key (keys %{$ttable->{$type}}){
	for my $expr (@{$ttable->{$type}->{$key}}){
	    $begs->{$expr} = $key;
	}
    }
    my $res = [];
    for (sort {length($b) <=> length($a) } keys %$begs){
	push @$res,[$_ ,$begs->{$_}];
    }
    return $res;
}


sub _match_front {
    my ($word,$matcher) = @_;
    for my $expr (@$matcher){
	if($word =~ m!^(?:\Q$expr->[0]\E)!gs){
	    $word =~ s!^(\Q$expr->[0]\E)!$expr->[1]!;
	    return $word;
	    print $word,"\t",$expr->[0],"\t",$expr->[1],"\n";
	}
    }
    return $word;
}

sub _match_vowels {
    my ($word,$matcher) = @_;
    my $vowels = _vowels();
    for my $expr (@$matcher){
#	print $expr->[0],"\n";
	while($word =~ m!(\Q$expr->[0]\E)([@$vowels])!gs){
	    my $repl = $expr->[1] ne "nc" ? $expr->[1] : "" ;
	    $word =~ s!($1)!$repl!;
	}
    }
    return $word;
}
 
sub _match_rest {
    my ($word,$matcher) = @_;
    for my $expr (@$matcher){
	while($word =~ m!(\Q$expr->[0]\E)!gs){
	    my $repl = $expr->[1] ne "nc" ? $expr->[1] : "" ;
	    $word =~ s!($1)!$repl!;
	}
    }
    return $word;
}
  
sub get_matcher {
    my $res = {};
    $res->{$_} = _make_beg_exprs($_) foreach ("beginning","vowel","generic"); 
    return $res;
}
sub code_word {
    my ($word, $matcher) = @_;
    $word = lc $word;
    $word =~ s!(.)\1{1,}!$1!gs;
    $word =~ s!(c)([iey])!s$2!gs;
    $word =~ s!c!k!gs;
    $word =  _match_front($word,$matcher->{"beginning"});
    $word = _match_vowels($word,$matcher->{"vowel"});
    $word = _match_rest($word,$matcher->{"generic"});    
    $word =~ s!\D!!gs;
    return $word;
}

1;
# testing the above
#my $word = shift ;
#die "need to pass a word to process!\n" unless $word;
#$word  = decode("utf8",$word);
#my $matcher = get_matcher();

#print code_word($word,$matcher),"\n";
