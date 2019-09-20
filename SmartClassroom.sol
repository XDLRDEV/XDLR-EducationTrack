pragma solidity^0.4.22;
contract SmartClassroom{
	
	int constant Like_value = 1;
	int constant Hate_value = 0;
	int constant Atdn_value = 1;
	string constant This_is_a_value_not_exist = "";
	string constant NuLL = "";
	
	
	struct Courseware{
		int tid ;
		string coursewareHash ;  
		int courseNo    ;  
	}
	
	struct Student {
		int uid ;
		string uname ;
		string specialty ; 
		int integral ;
		int NumberOfCourse;
		mapping(int => Course) course; 
		mapping(int => Scholarship)scholarship ; 
	}

	struct Teacher {
		int tid ;
		string tname ;
		int integral ; 
		int like_count;
		int hate_count;
		mapping(int => Assessment) assessment;
	}
	
	struct Assessment{
		int courseNo;
		int Like_count;
		int Hate_count;
	}
	
	struct Course{
		int no;
		int courseNo ;
		int score  ;
	}
	

	
	struct Scholarship{
		int sch_type;  
		int m1 ;
		int m2 ;
		int m3 ;
		int m4 ;
		int m5 ;
	}
	
	mapping(string => Courseware) courseware; 
	mapping(int => Student) student;
	mapping(int => Teacher) teacher;   
	 
	event ModifyCoursewareInfoEvent(string coursewareHash,int mod_type,int info);
	event DeleteCoursewareEvent(string coursewareHash);
	event ChangeEvent(int uid,int value,string Change_type);
	event TransEvent(int from,int to,int value,string Trans_type);
	event ElecEvent(int uid,int tid,int courseNo);
	event UpEvent(int tid,int courseNo,string coursewareHash);
	event LikeEvent(int tid,int courseNo);
	event HateEvent(int tid,int courseNo);
	event RlzEvent(int uid,int value,string url);
	event AsrEvent(int fromid,int toid,int value,string url);
	event AtdnEvent(int uid,int courseNo,int atdn_type);
	event IncrEvent(int uid,int inc_type,int sch_type,int score,string cause);
	
	/*
	函数功能：检查学生数据是否存在
	参数：学生id
	返回值：布尔型，存在返回true,不存在返回false
	*/
	function ExistStudent(int uid) public constant returns (bool){
		bool flag;
		if(student[uid].uid == uid){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	/*
	函数功能：检查教师或学生数据是否存在
	参数：教师id
	返回值：布尔型，存在返回true,不存在返回false
	*/
	function ExistTeacher(int tid) public constant returns (bool){
		bool flag;
		if((teacher[tid].tid) == (tid)){
			flag = true;
		}else{
			flag = false;
		}
		return flag;
	}
	
	/* *****************账户相关**************************************************************************/
	/*
	函数功能：创建学生账户
	参数：学生id，学生姓名，学生专业
	返回值：0：成功
			1：账户已经存在
	*/
	function CreateStudent(int uid,string uname,string specialty) public returns (int) {
		if(ExistStudent(uid) || ExistTeacher(uid)){
			
			return -1;
		} 
		student[uid] = Student(uid,uname,specialty,100,0);
		for(int i= 1;i<=5;i++){
			student[uid].scholarship[i] = Scholarship(i,0,0,0,0,0);
		}
		
		return 0;
	}
	
	/*
	函数功能：创建教师账户
	参数：教师id，教师姓名
	返回值：0：成功
			1：账户已经存在
	*/
	function CreateTeacher(int tid,string tname) public returns(int) {
		if(ExistStudent(tid) || ExistTeacher(tid)){
			return -1;
		} 
		teacher[tid] = Teacher(tid,tname,0,0,0);
		return 0;	
	}
	
	/*
	函数功能：学生或教师查询自己的账户
	参数：学生id/教师id
	返回值：-1：账户不存在
			其他值：账户积分，后依次返回id，姓名，专业(教师返回空值)
	*/
	function QueryIntegral(int id) public constant returns(int,int,string,string){
		if(!ExistStudent(id) && !ExistTeacher(id)){
			return(-1,-1," "," ");
		}
		if(ExistStudent(id)){
			return(student[id].integral,student[id].uid,student[id].uname,student[id].specialty);
		}else{
			return(teacher[id].integral,teacher[id].tid,teacher[id].tname,This_is_a_value_not_exist);
		}
	}
	
	/*
	函数功能：修改学生账户信息
	参数：学生id，修改信息：1：修改id          		info:修改姓名或专业时填写，其他情况可任意填写
							2：修改姓名				id:修改id时填写，其他情况可任意填写
							3：修改专业
	返回值：-1：学生账户不存在
			-2：修改信息错误，只能是1、2或3
			0：成功
	*/
	function ModifyStudentInfo(int uid,string info,int id) public returns(int){
		if(!ExistStudent(uid)){
			return -1;
		}
			student[uid].uname = info;	
			student[uid].uid = id;		
				
		
		return 0;
	}
	
	/*
	函数功能：修改教师账户信息
	参数：教师id，          id：修改id时填写，修改姓名时可任意填写
							info:修改姓名时填写修改id时可任意填写
							
	返回值：-1：学生账户不存在
			-2：修改信息错误，只能是1或2
			0：成功
	*/
	function ModifyTeacherInfo(int tid,string info,int id) public returns(int){
		if(!ExistTeacher(tid)){
			return -1;
		}	
			teacher[tid].tname = info;
			teacher[tid].tid = id;		
			
		
		return 0;
	}
	
	/*
	函数功能：为学生修改积分
	参数：学生id，修改积分数量（正值表示增加，负值表示减少），修改积分的理由
	返回值：-1：账户不存在
			-2：减少积分的情况下，账户中的积分不足
	*/	
	function ChangeIntegral_Student(int uid,int value,string Change_type) public returns (int){
		if(!ExistStudent(uid)){
			return -1;
		} 
		if(value <= 0){
			if(student[uid].integral + value < 0){
				return -2;
			}
		}
		student[uid].integral += value;
		emit ChangeEvent(uid,value,Change_type);
		return 0;
	}
	
	/*
	函数功能：为教师修改积分
	参数：教师id，修改积分数量（正值表示增加，负值表示减少），修改积分的理由
	返回值：-1：账户不存在
			-2：减少积分的情况下，账户中的积分不足
	*/
	function ChangeIntegral_Teacher(int tid,int value,string Change_type) public returns (int){
		if(!ExistTeacher(tid)){
			return -1;
		} 
		if(value <= 0){
			if(teacher[tid].integral + value < 0){
				return -2;
			}
		}
		teacher[tid].integral += value;
		emit ChangeEvent(tid,value,Change_type);
		return 0;
	}
	
	/*
	函数功能：删除学生账户
	函数参数：学生id
	返回值：-1：学生账户不存在
			0：成功
	*/
	function DeleteStudent(int uid) public returns(int){
		if(!ExistStudent(uid)){
			return -1;
		} 
		student[uid].uid = -1;
		return 0;
	}
	
	/*
	函数功能：删除教师账户
	函数参数：教师id
	返回值：-1：教师账户不存在
			0：成功
	*/
	function DeleteTeacher(int tid) public returns(int){
		if(!ExistTeacher(tid)){
			return -1;
		} 
		teacher[tid].tid = -1;
		return 0;
	}
	
	/*
	函数功能：学生之间转移积分
	参数：转出学生id，转入学生id，转移积分数量(需为正)，转移理由
	返回值：-1：转出学生账户不存在
			-2：转入学生账户不存在
			-3：转移积分为负
			-4：转出学生账户积分余额不足
			0：成功
	*/
	function TransactionIntegral(int fromid,int toid,int value,string Trans_type) public returns(int){
		if(!ExistStudent(fromid)){
			return -1;
		}
		if(!ExistStudent(toid)){
			return -2;
		}
		if(value <= 0){
			return -3;
		}
		if(student[fromid].integral < value){
			return -4;
		}
		student[fromid].integral -= value;
		student[toid].integral += value;
		emit TransEvent(fromid,toid,value,Trans_type);
		return 0;
	}
	
/* *****************选课相关**************************************************************************/
	
	/*
	函数功能：学生进行选课
	参数：学生id，课程号，教师id
	返回值：-1：学生账户不存在
			-2：教师账户不存在
			0：成功
	*/
	function ElectiveCourse(int uid,int courseNo,int tid) public returns(int) {
		if(!ExistStudent(uid)){
			return -1;
		} 
		if(!ExistTeacher(tid)){
			return -2;
		} 
		int n = student[uid].NumberOfCourse;
		student[uid].course[n] = Course(n,courseNo,-1);
		student[uid].NumberOfCourse ++;
		emit ElecEvent(uid,tid,courseNo);
		return 0;
	}
	
	/*
	函数功能：学生撤销选课
	参数：学生id
	返回值：-1：学生账户不存在
			-2：学生没有选这门课程
			0：成功
	*/
	function DeleteCourse(int uid,int courseNo) public returns(int){
		if(!ExistStudent(uid)){
			return -1;
		}
		int n = student[uid].NumberOfCourse;
		int flag = 0;
		int temp =-1;
		int i;
		for(i=0;i<n;i++){
			if(student[uid].course[n].courseNo == courseNo){
				flag = -1;
				temp = n;
			}
		}
		if(flag == 0){
			return -2;
		}
		for(i=temp;i<n-1;i++){
			student[uid].course[i] = student[uid].course[i+1];
		}
		student[uid].NumberOfCourse --;
		return 0;
	}
	
	/*
	函数功能：学生花费积分给教师点赞,教师获得相应积分
	参数：学生id，课程号，教师id
	返回值：-1：学生账户不存在
			-2：教师账户不存在
			-3：学生账户余额不足
			-4：学生没选这门课程
			0：成功
	*/
	function LikeCourse(int uid,int courseNo,int tid) public returns(int) {
		if(!ExistStudent(uid)){
			return -1;
		}
		if(!ExistTeacher(tid)){
			return -2;
		} 		
		if(student[uid].integral < Like_value){
			return -3;
		}
		int n = student[uid].NumberOfCourse;
		int flag = 0;
		int i;
		for(i=0;i<n;i++){
			if(student[uid].course[i].courseNo == courseNo){
			flag = -1;
			}
		}
		if(flag == 0){
			return -4;
		}
		student[uid].integral -= Like_value;
		teacher[tid].integral += Like_value;
		if((teacher[tid].assessment[courseNo].courseNo) != (courseNo)){
			teacher[tid].assessment[courseNo] = Assessment(courseNo,0,0);
		}
		teacher[tid].assessment[courseNo].Like_count ++;
		teacher[tid].like_count ++;
		emit LikeEvent(tid,courseNo);
		return 0;
	}
	
	/*
	函数功能：学生花费积分给教师点踩
	参数：学生id，课程号，教师id
	返回值：-1：学生账户不存在
			-2：教师账户不存在
			-3：学生账户余额不足
			-4：学生没选这门课程
			0：成功
	*/
	function HateCourse(int uid,int courseNo,int tid) public returns(int){
		if(!ExistStudent(uid)){
			return -1;
		}
		if(!ExistTeacher(tid)){
			return -2;
		} 		
		if(student[uid].integral < Hate_value){
			return -3;
		}
		int n = student[uid].NumberOfCourse;
		int flag = 0;
		for(int i=0;i<n;i++){
			if(student[uid].course[i].courseNo == courseNo){
			flag = -1;
			}
		}
		if(flag == 0){
			return -4;
		}
		student[uid].integral -= Hate_value;
		if((teacher[tid].assessment[courseNo].courseNo) != (courseNo)){
			teacher[tid].assessment[courseNo] = Assessment(courseNo,0,0);
		}
		teacher[tid].assessment[courseNo].Hate_count ++;
		teacher[tid].hate_count ++;
		emit HateEvent(tid,courseNo);
		return 0;
	}
	
	/*
	函数功能：学生发布悬赏
	参数：学生id，悬赏积分数量，相关url
	返回值：-1：学生账户不存在
			-2：学生账户余额不足
			0：成功
	*/
	function ReleaseReward(int uid,int value,string url) public returns(int) {
		if(!ExistStudent(uid)){
			return -1;
		}
		if(student[uid].integral < value){
			return -2;
		}
		student[uid].integral -= value;
		emit RlzEvent(uid,value,url);
		return 0;
	}
	
	/*
	函数功能：学生完成悬赏
	参数：发布学生id，回答学生id，获得积分数量，相关url
	返回值：-1：发布悬赏的账户不存在
			-2：获得悬赏的账户不存在
			0：成功
	*/
	function AnswerReward(int fromid,int toid,int reward,string url) public returns(int) {
		if(!ExistStudent(fromid)){
			return -1;
		}
		if(!ExistStudent(toid)){
			return -2;
		}
		student[toid].integral += reward;
		emit AsrEvent(fromid,toid,reward,url);
		return 0;
	}
	
	/*
	函数功能：根据学生到课率给予积分并上链
	参数：学生id，课程号,atdn_type（-1表示缺席，0表示迟到，1表示到课）
	返回值：-1：学生账户不存在
			-2：学生没有选这门课程
			-3：类型设置错误，只能是-1，0，1
			0：成功
	*/
	function RateOfAttendance(int uid,int courseNo,int atdn_type) public returns(int) {
		if(!ExistStudent(uid)){
			return -1;
		}
		int n = student[uid].NumberOfCourse;
		int flag = 0;
		int i;
		for(i=0;i<n;i++){
			if(student[uid].course[i].courseNo == courseNo){
			flag = -1;
			}
		}
		if(flag == 0){
			return -2;
		}
		if(atdn_type*atdn_type*atdn_type-atdn_type !=0){

			return -3;
		}
		if(atdn_type == 1){
		ChangeIntegral_Student(uid,Atdn_value,"RateOfAttendance");
		}
		emit AtdnEvent(uid,courseNo,atdn_type);
		return 0;
	}
	
	/*
	函数功能：为学生增加模块分，并上链
	参数：学生id，模块号（1-5），学期数（1-8），增加分数，增加原因
	返回值：-1：学生账户不存在
			-2：学期数错误，只能是1-8的整数
			-3：模块号错误，只能是1-5的整数
			-4：增加分数错误，增加后分数将超过100
			0：成功
	*/
	function ScholarshipIncreasement(int uid,int inc_type,int sch_type,int score,string cause) public returns(int) {
		if(!ExistStudent(uid)){
			return -1;
		}
		if(sch_type < 1 || sch_type >8){
			return -2;
		}
		if(inc_type < 1 || inc_type >5){
			return -3;
		}
		if(inc_type == 1){
			
			if(student[uid].scholarship[sch_type].m1 + score <100) {
				student[uid].scholarship[sch_type].m1 += score;
			}else{
				return -4;
			} 
		}else if(inc_type == 2){
			
			if(student[uid].scholarship[sch_type].m2 +score < 100) {
				student[uid].scholarship[sch_type].m2 += score;
			}else{
				return -4;
			} 
		}else if(inc_type == 3){
			if(student[uid].scholarship[sch_type].m3 + score <100) {
				student[uid].scholarship[sch_type].m3 += score;
			}else{
				return -4;
			}  
		}else if(inc_type == 4){
			
			if(student[uid].scholarship[sch_type].m4 + score < 100) {
				student[uid].scholarship[sch_type].m4 += score;
			}else{
				return -4;
			}   
		}else {
			if(student[uid].scholarship[sch_type].m5 + score < 100) {
				student[uid].scholarship[sch_type].m5 += score;
			}else{
				return -4;
			}   
		}
		emit IncrEvent(uid,inc_type,sch_type,score,cause);
		return 0;
	}
	
	/*记录学生课程成绩
		变量说明：	uid：学生账户id
					courseNo：课程号
					score：该课程的分数
					flag：	-1：学生账户不存在
							-2：分数设置错误，应为0-100的整数
							-3：已经记录过分数了
							0：成功
	*/
	function CourseScore(int uid,int courseNo,int score) public returns(int) {
		int temp;
		if(!ExistStudent(uid)){
			return -1;
		} 
		if(score <0 || score > 100){
			return -2;
		}
		int n = student[uid].NumberOfCourse;
		int flag = 0;
		int i;
		for(i=0;i<n;i++){
			if(student[uid].course[i].courseNo == courseNo){
			flag = -1;
			temp = n;
			}
		}
		if(flag == 0){
			return -3;
		}
		student[uid].course[temp].score = score;
		return 0;
	}
	
	/*
	函数功能：学生查询自己某一学期的模块分数
	参数：学生id，学期数
	返回值：第一个值：  -1：学生账户不存在
						0：	成功
			后面五个值分别依次是m1，m2,m3,m4,m5的分数
	*/
	function QueryStudentScholarship(int uid,int sch_type) public constant returns(int,int,int,int,int,int){
		if(!ExistStudent(uid)){
			return (-1,-1,-1,-1,-1,-1);
		}
		int s1;
		int s2;
		int s3;
		int s4;
		int s5;
		s1 = student[uid].scholarship[sch_type].m1;
		s2 = student[uid].scholarship[sch_type].m2;
		s3 = student[uid].scholarship[sch_type].m3;
		s4 = student[uid].scholarship[sch_type].m4;
		s5 = student[uid].scholarship[sch_type].m5;
		return (0,s1,s2,s3,s4,s5);
	}
	
	/*
	函数功能：教师查询自己某一课程的点赞数和踩数
	参数：教师id，课程号
	返回值： like_count：点赞数量，hate_count：点踩数量(值为“-2”表示课程不存在或者无人评论过,值为-1表示教师不存在)
	*/
	function QueryAssessmentByCourse(int tid,int courseNo) public constant returns(int,int){
		int hate_count = -2;
		int like_count = -2;
		if(!ExistTeacher(tid)){
			hate_count = -1;
			like_count = -1;
			return (like_count,hate_count);
		}
		hate_count = teacher[tid].assessment[courseNo].Hate_count;
		like_count = teacher[tid].assessment[courseNo].Like_count;
		return (like_count,hate_count);
	}
	
/* *****************课件相关**************************************************************************/
	
	/*
	函数功能：教师将课件的哈希值上链
	参数：教师id，课程号，课件哈希
	返回值：-1：教师不存在
			-2：该哈希值已上链
			0：成功
	*/
	function UpCourseware(int tid,int courseNo,string coursewareHash) public returns(int){
		if(!ExistTeacher(tid)){
			return -1;
		} 
		if(sha256(courseware[coursewareHash].coursewareHash) == sha256(coursewareHash)){
			return -2;
		}
		courseware[coursewareHash] = Courseware(tid,coursewareHash,courseNo);
		emit UpEvent(tid,courseNo,coursewareHash);
		return 0;
	}
	
	/*
	函数功能：教师查询某哈希对应课件的信息
	参数：课件哈希
	返回值：flag：  -1：课件哈希不存在
					0：成功
			tea_id：课件所属教师，cou_no：课件所属课程；
	*/
	function Confirmation(string coursewareHash) public constant returns(int,int,int){
		if(sha256(courseware[coursewareHash].coursewareHash) != sha256(coursewareHash)){
			return (-1,-1,-1);
		}
		int tea_id = courseware[coursewareHash].tid; 
		int cou_no = courseware[coursewareHash].courseNo;
		return (0,tea_id,cou_no);
	}
	
	/*
	函数功能：修改课件哈希对应的信息
	参数：课件哈希，修改类型：	1：修改所属教师id   ，修改值
								2：修改所属课程号
	返回值：-1：课件哈希不存在
			-2：修改类型错误
			0：成功
	*/
	function ModifyCoursewareInfo(string coursewareHash,int mod_type,int info) public returns (int){
		if(sha256(courseware[coursewareHash].coursewareHash) != sha256(coursewareHash)){
			return -1;
		}
		if(mod_type == 1){
			courseware[coursewareHash].tid = info;
			emit ModifyCoursewareInfoEvent(coursewareHash,mod_type,info);
			return 0;
		}else if(mod_type == 2){
			courseware[coursewareHash].courseNo = info;
			emit ModifyCoursewareInfoEvent(coursewareHash,mod_type,info);
			return 0;
		}else{
			return -2;
		}
	}
	
	/*
	函数功能：删除课件哈希对应的信息
	参数：要删除的课件哈希
	返回值：-1：课件哈希不存在
			0：成功
	*/
	function DeleteCourseware(string coursewareHash) public returns (int){
		if(sha256(courseware[coursewareHash].coursewareHash) != sha256(coursewareHash)){
			return -1;
		}
		courseware[coursewareHash].coursewareHash = "";
		emit DeleteCoursewareEvent(coursewareHash);
		return 0;
	}
	
	/*	教师查询自己总的点赞数和点踩数
			变量说明：	tid：教师账户id
						like_count/hate_count：	-1:教师账户不存在
												其他非负值：分别表示收到的点赞和点踩的数量
	*/											
	
	function QueryAssessment(int tid) public constant returns(int,int){
		if(!ExistTeacher(tid)){
			return(-1,-1);
		}
		int like_count = teacher[tid].like_count;
		int hate_count = teacher[tid].hate_count;
		return(like_count,hate_count);
	}
	
	/*
	函数功能：学生查询自己所有的选课
	参数：学生id
	返回值：c[20]，其中c[0]为-1表示学生不存在，c[0] = 0为成功，后面十九个值分别为课程号，如果有剩余则为0
	
	
	*/
	function QueryCourse(int uid) public returns (int[20]){
		int[20] storage c;
		if(!ExistStudent(uid)){
			c[0] = -1;
			return c;
		}
		int n = student[uid].NumberOfCourse;
		uint i = 1;
		int j = 1;
		for(j=0;j<n;j++){
				c[i] = student[uid].course[j].courseNo;
				i++;
				}
		return c;
	}


}