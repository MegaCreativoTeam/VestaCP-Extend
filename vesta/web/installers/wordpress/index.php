<?php
//AUTOMATIC WORDPRESS INSTALLER by Maskoid

error_reporting(NULL);
ob_start();
$TAB = 'WordPress';

// Main include
include($_SERVER['DOCUMENT_ROOT']."/inc/main.php");

// Check user
if ($_SESSION['user'] != 'admin') {
    header('Location: /list/user');
    exit;
}

// Check POST request
if (!empty($_POST['ok'])) {

    // Check token
    if ((!isset($_POST['token'])) || ($_SESSION['token'] != $_POST['token'])) {
        header('location: /login/');
        exit();
    }

    // Check empty fields
    if (empty($_POST['v_domain'])) $errors[] = __('domain');
    if (empty($_POST['v_path'])) $errors[] = __('install_path');
    if (empty($_POST['v_admin_user'])) $errors[] = __('username');
    if (empty($_POST['v_admin_passwd'])) $errors[] = __('password');
    if (empty($_POST['v_blog_title'])) $errors[] = __('blog title');
    if (empty($_POST['v_admin_email'])) $errors[] = __('admin email');
    if (empty($_POST['v_admin_fname'])) $errors[] = __('first name');
    if (empty($_POST['v_admin_lname'])) $errors[] = __('lastname');
    if (empty($_POST['v_http'])) $errors[] = __('http/https');
    if (empty($_POST['v_send_email'])) $errors[] = __('send email');
    if (!empty($errors[0])) {
        foreach ($errors as $i => $error) {
            if ( $i == 0 ) {
                $error_msg = $error;
            } else {
                $error_msg = $error_msg.", ".$error;
            }
        }
        $_SESSION['error_msg'] = __('Field "%s" can not be blank.',$error_msg);
    }

    // Validate email
    if ((!empty($_POST['v_admin_email'])) && (empty($_SESSION['error_msg']))) {
        if (!filter_var($_POST['v_admin_email'], FILTER_VALIDATE_EMAIL)) {
            $_SESSION['error_msg'] = __('Please enter valid Admin email address.');
        }
    }

    if ((!empty($_POST['v_send_email'])) && (empty($_SESSION['error_msg']))) {
        if (!filter_var($_POST['v_send_email'], FILTER_VALIDATE_EMAIL)) {
            $_SESSION['error_msg'] = __('Please enter valid email address to send login details.');
        }
    }

    // Check password length
    if (empty($_SESSION['error_msg'])) {
        $pw_len = strlen($_POST['v_admin_passwd']);
        if ($pw_len < 6 ) $_SESSION['error_msg'] = __('Password is too short.',$error_msg);
    }

    // Install WordPress
    if (empty($_SESSION['error_msg'])) {
        // assign input to variable
        $domain = escapeshellarg($_POST['v_domain']);
        $path = escapeshellarg($_POST['v_path']);
        $admin_user = escapeshellarg($_POST['v_admin_user']);
        $admin_passwd = escapeshellarg($_POST['v_admin_passwd']);
        $admin_email = escapeshellarg($_POST['v_admin_email']);
        $blog_title = escapeshellarg($_POST['v_blog_title']);
        $fname = escapeshellarg($_POST['v_admin_fname']);
        $lname = escapeshellarg($_POST['v_admin_lname']);
        $https = escapeshellarg($_POST['v_http']);
        $www = escapeshellarg($_POST['v_www']);
        $send_email = escapeshellarg($_POST['v_send_email']);
        
        exec (VESTA_CMD."v-install-wordpress ".$user." ".$domain." ".$path." ".$admin_user." ".$admin_passwd." ".$admin_email." ".$blog_title." ".$fname." ".$lname." ".$https." ".$www." ".$blog_url, $output, $return_var);
       
        /*echo "<pre>"; 
            if ($ret == 0) {                // check status code. if successful 
                foreach ($output as $line) {  // process array line by line 
                    echo "$line \n"; 
                } 
            } else { 
                echo "Error in command";    // if unsuccessful display error 
            } 
            echo $ok_message;
        echo "</pre>"; */

        check_return_code($return_var,$output);
        unset($output);
        unlink($v_password);

        if ($_POST['v_www'] == 'www') {
            $blog_url = "{$_POST['v_http']}://www.{$_POST['v_domain']}{$_POST['v_path']}";
            $ok_message = "WordPress installed success. <a href=\"{$blog_url}\" target=\"blank\"> Visit</a>";
        }
        else {            
            $blog_url = "{$_POST['v_http']}://{$_POST['v_domain']}{$_POST['v_path']}";
            $ok_message = "WordPress installed success. <a href=\"{$blog_url}\" target=\"blank\"> Visit</a>";
        }
        
        $wp_install_logs = '<div class"card">';
        $wp_install_logs .= '    <div class="card-header"><strong>'.__('Your new WordPress site has been successfully set up at').'</strong></div>';
        $wp_install_logs .= '    <div class="card-body">';
        $wp_install_logs .= '       <strong>Site:</strong><a href="'.$blog_url.'/wp-login.php" target="blank">'.$blog_url . '</a><br/>';
        $wp_install_logs .= '       <strong>Log in here:</strong> <a href="'.$blog_url.'/wp-login.php" target="blank">'.$blog_url.'/wp-login.php</a><br/>';
        $wp_install_logs .= '       <strong>E-mail:</strong> ' . str_replace("'",'',$admin_email) . '<br/>';
        $wp_install_logs .= '       <strong>Username:</strong> ' . str_replace("'",'',$admin_user) . '<br/>';
        $wp_install_logs .= '       <strong>Password:</strong> ' . str_replace("'",'',$admin_passwd) . '<br/>';
        $wp_install_logs .= '   </div>';
        $wp_install_logs .= '</div>';
        $_SESSION['ok_msg'] = $ok_message;
        $_SESSION['wp_install_logs'] = $wp_install_logs;

    }

/* This module currently not required because WP-CLI installation send confirmation email but without password.
    // Email login credentials
    if ((!empty($send_email)) && (empty($_SESSION['error_msg']))) {
        $to = $send_email;
        $subject = __("WordPress Installed Details");
        $hostname = exec('hostname');
        $from = __('MAIL_FROM',$hostname);
        $mailtext = __('DATABASE_READY',$user."_".$_POST['v_admin_user'],$user."_".$_POST['v_admin_user'],$_POST['v_admin_passwd'],$blog_url);
        send_email($to, $subject, $mailtext, $from);
    }
*/

    // Flush field values on success
    if (empty($_SESSION['error_msg'])) {
        unset($v_password);
        unset($v_path);
        unset($v_blog_title);
    }
}


// Get user list of domains
exec (VESTA_CMD."v-list-web-domains $user json", $output, $return_var);
$data = json_decode(implode('', $output), true);
$data = array_reverse($data,true);


// Render page
render_page($user, $TAB, 'install_wp');

// Flush session messages
unset($_SESSION['error_msg']);
unset($_SESSION['ok_msg']);
unset($_SESSION['wp_install_logs']);

// Back uri
$_SESSION['back'] = $_SERVER['REQUEST_URI'];