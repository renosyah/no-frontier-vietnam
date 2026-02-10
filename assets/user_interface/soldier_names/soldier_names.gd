extends Node
class_name SoldierNames

const us_first_names = [
	"James","Robert","William","Thomas","Charles","David","Richard","Michael",
	"John","Paul","Steven","Kenneth","Donald","Larry","Gary","Frank","Edward",
	"Raymond","Joseph","Daniel","Mark","Brian","Alan","Ronald","Dennis","Patrick",
	"Henry","Carl","Walter","Eugene","Douglas","Victor","Philip","Anthony",
	"Samuel","Louis","George","Curtis","Arthur","Scott","Howard","Ernest",
	"Russell","Marvin","Leonard","Nicholas","Jack","Harold","Benjamin","Chester",
	"Floyd","Norman","Melvin","Wesley","Bobby","Roy","Calvin","Jerry","Alfred",
	"Stanley","Roger","Terry","Keith","Bruce","Dale","Wayne","Clifton","Vernon",
	"Irving","Milton","Sidney","Aaron","Leon","Peter","Karl","Marcus"
]

const us_family_names = [
	"Walker","Miller","Johnson","Anderson","Peterson","Collins","Hayes","Thompson",
	"Reynolds","Simmons","Carter","Baker","Harris","Wilson","Mitchell","Turner",
	"Morgan","Brooks","Bennett","Cooper","Sullivan","OConnor","Foster","Price",
	"Howard","Murphy","Wallace","Jenkins","Barnes","Powell","Reed","Coleman",
	"Rogers","Russo","Ward","Patterson","Henderson","Long","Fisher","McAllister",
	"Graham","Kelley","Porter","Diaz","Chavez","Marino","Obrien","Donovan","Kim",
	"Lee","Wright","Matthews","Scott","Grant","King","Stewart","Alexander",
	"Roberts","Lawson","Young","Park","Marshall","Nolan","Freeman","Adams",
	"Rosen","Goldstein","Kaplan","Feldman","Bernstein","Kowalski","Nowak",
	"Schmidt","Hoffman","Brown"
]

const nva_first_names = [
	"Anh","Bao","Binh","Cuong","Duc","Dung","Hai","Hieu",
	"Hoa","Hoang","Hung","Khanh","Kien","Lam","Loc","Long",
	"Minh","Nam","Phong","Phuc","Quang","Son","Tai","Thanh",
	"Thang","Tuan","Viet","Vinh","Xuan","An","Chien","Dat",
	"Diep","Giang","Hanh","Hiep","Huy","Khai","Liem","Manh",
	"Nghia","Nhan","Phat","Quan","Sang","Tam","Thien","Tho",
	"Tri","Trung","Van","Yen","Luong","Phu","Toan","Tung"
]

const nva_family_names = [
	"Nguyen","Tran","Le","Pham","Hoang","Huynh","Phan","Vu",
	"Vo","Dang","Bui","Do","Ho","Ngo","Duong","Ly",
	"Trinh","Cao","Dinh","Mai","Ta","Tong","Thai","Chu",
	"Luu","Quach","Vuong","Lam","Kieu","Tien","Ton","Truong",
	"Ha","Phung","Dao","Ta","Trieu","Vinh","Kim","Thach"
]

static func get_random_us_name() -> String:
	var first_names = us_first_names[randi() % us_first_names.size()]
	var family_names = us_family_names[randi() % us_family_names.size()]
	return "%s %s" % [first_names, family_names]

static func get_random_viet_name():
	var first_names = nva_family_names[randi() % nva_family_names.size()]
	var family_names = nva_family_names[randi() % nva_family_names.size()]
	return "%s %s" % [first_names, family_names]
