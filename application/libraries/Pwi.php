<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed'); 

/**
 * Pwi Lib ported from the orginal pwi-api for minimal usage like login and 
 * basic information.
 *
 * @package	    Pwi
 * @category    API
 * @author      Vignesh Rajagopalan <vignesh@campuspry.com>
 * @link	    http://aarvay.in/pwi
 */

require_once('phpQuery.php');

class Pwi {
    protected $regno; //Register Number of the Student.
    protected $pass; //Password => Birthday(ddmmyyyy)
    
    /**
     * Param to find if the user has successfully authenticated against the PWI
     */
    private $is_authenticated;

    /**
     * Param that holds whether the user is from Main Campus or from 
     * SRC Kumbakonam
     */
    private $campus;
    
    /**
     * Initialize the API
     */
    public function __construct($params) {
        $this->set_regno($params['regno']);
        $this->set_pass($params['pass']);
        $this->is_authenticated = false;
        $this->set_curl_behaviour();
        $this->login_to_pwi();
    }
    
    /**
     * Set the params
     */
    private function set_regno($regno) {
        $this->regno = $regno;
        return $this;
    }
    
    private function set_pass($pass) {
        $this->pass = $pass;
        return $this;
    }
    
    /**
     * Set the required CURL Behaviour
     */
    private function set_curl_behaviour() {
        $options = array(CURLOPT_POST => true,
                         CURLOPT_FOLLOWLOCATION => true,
                         CURLOPT_COOKIEJAR => "cookies.txt",
                         CURLOPT_COOKIEFILE => "cookies.txt",
                         CURLOPT_RETURNTRANSFER => true,
                         CURLOPT_HEADER => false
                   );
        $this->ch = curl_init();
        curl_setopt_array($this->ch, $options);
        return $this;   
    }
    
    /**
     * Login to the PWI
     */
    private function login_to_pwi() {
        if (isset($this->regno) && isset($this->pass)) {
            $ch = $this->ch;
            
            curl_setopt($ch, CURLOPT_URL, "http://webstream.sastra.edu/sastrapwi/usermanager/youLogin.jsp");
            curl_setopt($ch, CURLOPT_POSTFIELDS, "txtRegNumber=iamalsouser&txtPwd=thanksandregards&txtSN={$this->regno}&txtPD={$this->pass}&txtPA=1");
            curl_setopt ($ch, CURLOPT_REFERER, "http://webstream.sastra.edu/sastrapwi/usermanager/youLogin.jsp");
            $this->home = curl_exec($ch);
            $login_page = $this->home;
            
            $match_count = preg_match("/Login failed, Username and Password do not match/",$login_page, $matches);
            if($match_count > 0) $this->is_authenticated = false;
            else $this->is_authenticated = true;
            
            $match_count = preg_match("/SASTRA-Srinivasa Ramanujam Center/",$login_page, $matches);
            if($match_count > 0) $this->campus = "SRC";
            else $this->campus = "Main";
        } 
        else die("Register Number or Password not set.");
    }
    
    /**
     * Get the login status of the current user
     */
    public function get_auth_status() {
        return $this->is_authenticated;
    }
    
    /**
     * Get campus that student belong. Well useful, as certain 
     * operations are not available for SRC campus students on PWI.
     */
    public function get_campus() {
        return $this->campus;
    }
    
    /**
     * Throw error when user is not authenticated properly
     */
    public function auth_error() {
        return json_encode(array("status" => "false", "error" => "User not authenticated"));
    }
    
    /**
     * Get Basic student details
     */
    public function get_student_details() {
        if($this->get_auth_status()) {
            phpQuery::newDocument($this->home);
            $list = pq('ul.leftnavlinks01');
            
            $details = array();
            $details["REGNO"] = $this->regno;
            $details["NAME"] =  trim(pq($list)->find('li:eq(0)')->text());
            $details["GROUP"] =  trim(pq($list)->find('li:eq(1)')->text());
            $details["SEM"] =  trim(pq($list)->find('li:eq(3)')->text());
            
            return json_encode($details);
        }
        else return $this->auth_error();
    }
}

/* End of file Pwi.php */
