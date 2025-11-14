<?php

function my_custom_style() {
    echo '<style>
    header { background: #2c3e50 !important; color: white !important; padding: 20px !important; }
    h1 { color: white !important; }
    .home main::before { content: "Benvenuto - anmedyns @ 42 School"; display: block; background:rgb(231, 177, 0); color: white; padding: 15px; text-align: center; }
    </style>';
}
add_action('wp_head', 'my_custom_style');
?>
oiuy
