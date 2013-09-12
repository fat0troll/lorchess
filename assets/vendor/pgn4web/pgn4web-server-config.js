/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2012 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

//
// some parameters that might need reconfiguring for implementing pgn4web on your server
//

"use strict";

//
// the email for the project, default = 'pgn4web@casaschi.net'
// used by: home.html, board-generator.html and pgn4web.js
//
var pgn4web_project_email = 'pgn4web@casaschi.net';
//

//
// the URL for the project's blog, default = 'http://pgn4web-blog.casaschi.net'
// used by: home.html
//
var pgn4web_project_blog = 'http://pgn4web-blog.casaschi.net';
//

//
// the URL for the board widged to be used in the board-generator tool, default = full URL of local board.html file = pgn4web_board_url = location.protocol + "//" + location.hostname+location.pathname.substr(0, location.pathname.lastIndexOf("/")) + "/board.html";
// used by: board-generator.html
//
var pgn4web_board_url = location.protocol + "//" + location.hostname+location.pathname.substr(0, location.pathname.lastIndexOf("/")) + "/board.html";
// var pgn4web_board_url = 'http://pgn4web-board.casaschi.net/';
//

//
// the URL for the board generator tool, default = 'board-generator.html'
// used by: board-generator.html, widget.html
//
var pgn4web_generator_url = 'board-generator.html';
// var pgn4web_generator_url = 'http://pgn4web-board-generator.casaschi.net/';
//

//
// login/key pair for the bitly URL shortening service, default blank (then tinyurl is used instead)
// used by: board-generator.html
//
var pgn4web_bitly_login = "";
var pgn4web_bitly_apiKey = "";
// var pgn4web_bitly_login = "";
// var pgn4web_bitly_apiKey = "";
//

//
// pointer URL for the live games broadcast, default = '.'
// used by: live.html, live-multi.html, live-mosaic.html
//
var pgn4web_live_pointer_url = '.';
// var pgn4web_live_pointer_url = 'http://pgn4web-live.casaschi.net';
//

//
// the URL for the game viewer tool, default = 'demo.html?frame=pgn_form'
// used by: home.html
//
var pgn4web_viewer_url = 'demo.html?frame=pgn_form';
// var pgn4web_viewer_url = 'viewer.php';
//

