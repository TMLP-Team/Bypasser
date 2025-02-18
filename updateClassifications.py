import os
from sys import exit
from datetime import datetime
from hashlib import sha512
from json import loads
from re import findall
try:
	from requests import get
except:
	def get(url:str, *parameters:None) -> None:
		return None
	print("Cannot import ``get`` from the ``requests`` library. Fetching from URLs will be unavailable. ")
	print("Please try to install the ``requests`` library correctly via ``python -m pip install requests`` or ``apt-get install python3-requests``. ")
try:
	os.chdir(os.path.abspath(os.path.dirname(__file__)))
except:
	pass
EXIT_SUCCESS = 0
EXIT_FAILURE = 1
EOF = (-1)


class Classification:
	def __init__(self:object, s:tuple|list|set|None = None) -> object:
		self.__s = set(s) if isinstance(s, (tuple, list, set)) else set()
		self.__pattern = "^[A-Za-z][A-Za-z0-9_]*(?:\\.[A-Za-z][A-Za-z0-9_]*)+$"
		self.__exclusionList = ["com.google.android.gms"]
	def __exclude(self:object) -> int:
		cnt = 0
		for package in self.__exclusionList:
			if package in self.__s:
				self.__s.remove(package)
				cnt += 1
		return cnt
	def __getTxt(self:object, filePath:str) -> str|None: # get ``*.txt`` content
		for coding in ("utf-8", "ANSI", "utf-16", "gbk"): # codings (add more codings here if necessary)
			try:
				with open(filePath, "r", encoding = coding) as f:
					content = f.read()
				return content[1:] if content.startswith("\ufeff") else content # if utf-8 with BOM, remove BOM
			except (UnicodeError, UnicodeDecodeError):
				continue
			except:
				return None
		return None
	def __getUrl(self:object, url:str) -> tuple: # get URL content
		try:
			r = get(url)
			if r is None:
				return (False, "The ``get`` is currently unavailable. ")
			else:
				return (True, r.text)
		except BaseException as e:
			return (False, str(e))
	def configureSet(self:object, s:set|tuple|list, updateSwitch:bool = True) -> bool:
		if isinstance(s, (set, tuple, list)) and isinstance(updateSwitch, bool):
			if not updateSwitch:
				self.__s.clear()
			self.__exclude()
			originalSize = len(self.__s)
			self.__s.update(s)
			self.__exclude()
			currentSize = len(self.__s)
			sizeDelta = currentSize - originalSize
			print("Successfully updated {0} package name(s). ".format(sizeDelta))
			return True
		else:
			print("The parameters passed are in wrong types. ")
			return False
	def configureFile(self:object, filePath:str, updateSwitch:bool = True) -> bool:
		if isinstance(filePath, str) and isinstance(updateSwitch, bool):
			content = self.__getTxt(filePath)
			if isinstance(content, str):
				if not updateSwitch:
					self.__s.clear()
				self.__exclude()
				originalSize = len(self.__s)
				for line in content.splitlines():
					self.__s.update(findall(self.__pattern, line))
				self.__exclude()
				currentSize = len(self.__s)
				sizeDelta = currentSize - originalSize
				print("Successfully updated {0} package name(s) from the file \"{1}\". ".format(sizeDelta, filePath))
				return True
			else:
				print("Failed to update from the file \"{0}\". ".format(filePath))
		else:
			print("The parameters passed are in wrong types. ")
			return False
	def configureUrl(self:object, url:str, updateSwitch:bool = True) -> bool:
		if isinstance(url, str) and isinstance(updateSwitch, bool):
			status, content = self.__getUrl(url)
			if status:
				if not updateSwitch:
					self.__s.clear()
				self.__exclude()
				originalSize = len(self.__s)
				vector = loads(content)
				if isinstance(vector, list):
					for v in vector:
						if isinstance(v, dict) and "name" in v:
							self.__s.update(findall(self.__pattern, v["name"]))
				self.__exclude()
				currentSize = len(self.__s)
				sizeDelta = currentSize - originalSize
				print("Successfully updated {0} package name(s) from the URL \"{1}\". ".format(sizeDelta, url))
				return True
			else:
				print("Failed to update from the URL \"{0}\". Details are as follows. \n\t{1}".format(url, content))
				return False
		else:
			print("The parameters passed are in wrong types. ")
			return False
	def intersection(self:object, other:object) -> set:
		return other.intersection(self.__s)
	def writeTo(self:object, filePath:str, encoding:str = "utf-8") -> bool:
		try:
			with open(filePath, "w", encoding = encoding) as f:
				f.write(str(self))
			print("Successfully wrote {0} lines to the file \"{1}\". ".format(len(self), filePath))
			return True
		except BaseException as e:
			print("Failed to write to the file \"{0}\" due to exceptions. Details are as follows. \n\t{1}".format(filePath, e))
			return False
	def __len__(self:object) -> int:
		return len(self.__s)
	def __str__(self:object) -> str:
		return "\n".join(sorted(self.__s))


def updateSHA512(srcFp:str, encoding:str = "utf-8") -> bool:
	if isinstance(srcFp, str) and os.path.isdir(srcFp) and isinstance(encoding, str):
		successCnt, filePaths = 0, []
		for root, dirs, files in os.walk(srcFp):
			for fileName in files:
				filePath = os.path.join(root, fileName)
				if os.path.splitext(fileName)[1] == ".sha512":
					try:
						os.remove(filePath)
					except:
						pass
				else:
					filePaths.append(filePath)
		totalCnt = len(filePaths)
		length = len(str(totalCnt))
		for i, filePath in enumerate(filePaths):
			try:
				if filePath == os.path.join(srcFp, "webroot.zip"):
					digests = []
					for root, dirs, files in os.walk(os.path.join(srcFp, "webroot")):
						for fileName in files:
							fileP = os.path.join(root, fileName)
							with open(fileP, "rb") as f:
								digests.append(sha512(f.read()).hexdigest() + "  " + fileP)
					digests.sort()
					digest = "\n".join(digests)
				else:
					with open(filePath, "rb") as f:
						digest = sha512(f.read()).hexdigest()
			except BaseException as e:
				print("[{{0:0>{0}}}] \"{{1}}\" -> {{2}}".format(length).format(i + 1, filePath, e))
				continue
			try:
				with open(filePath + ".sha512", "w", encoding = encoding) as f:
					f.write(digest)
				successCnt += 1
				print("[{{0:0>{0}}}] \"{{1}}\" -> {{2}}".format(length).format(i + 1, filePath, digest if digest.isalnum() else digest.split("\n")))
			except BaseException as e:
				print("[{{0:0>{0}}}] \"{{1}}\" -> {{2}}".format(length).format(i + 1, filePath, e))
		print("Successfully generated {0} / {1} SHA-512 value file(s) at the success rate of {2:.2f}%. ".format(successCnt, totalCnt, successCnt * 100 / totalCnt) if totalCnt else "No SHA-512 value files were generated. ")
		return successCnt == totalCnt
	else:
		return False

def gitPush() -> bool:
	commitMessage = "Regular Update ({0})".format(datetime.now().strftime("%Y%m%d%H%M%S"))
	print("The commit message is \"{0}\". ".format(commitMessage))
	if __import__("platform").system().upper() == "WINDOWS":
		commandlines = []
	else:
		commandlines = [																			\
			"find . -type d -exec chmod 755 {} \\;", 														\
			"find . ! -name \"LICENSE\" ! -name \"build.sh\" ! -name \"*.sha512\" -type f -exec chmod 644 {} \\;", 	\
			"find . -name \"*.sha512\" -type f -exec chmod 444 {} \\;", 										\
			"chmod 444 \"LICENSE\"", 																\
			"chmod 744 \"build.sh\"", 																\
			"find . -name \"*.sh\" -exec bash -n {} \\;"													\
		]
	commandlines.extend(["git add .", "git commit -m \"{0}\"".format(commitMessage), "git push"])
	for commandline in commandlines:
		if os.system(commandline) != 0:
			return False
	return True

def main() -> int:
	# Parameters #
	filePathB = "Classification/classificationB.txt"
	url = "https://modules.lsposed.org/modules.json"
	filePathC = "Classification/classificationC.txt"
	filePathD = "Classification/classificationD.txt"
	srcFolderPath = "src"
	bRet = True
	
	# Update $B$ #
	classificationB, classificationC, classificationD = Classification(), Classification(), Classification()
	bRet = classificationB.configureFile(filePathB) and bRet
	bRet = classificationB.configureUrl(url) and bRet
	bRet = classificationB.writeTo(filePathB) and bRet
	
	# Compute Intersections #
	bRet = classificationC.configureFile(filePathC)
	bRet = classificationD.configureFile(filePathD)
	setBC = classificationB.intersection(classificationC)
	setBD = classificationB.intersection(classificationD)
	setCD = classificationC.intersection(classificationD)
	if setBC:
		print("There {0} in both Classification $B$ and Classification $C$. ".format("are {0} elements".format(len(setBC)) if len(setBC) > 1 else "is {0} element".format(len(setBC))))
		print(setBC)
		bRet = False
	if setBD:
		print("There {0} in both Classification $B$ and Classification $D$. ".format("are {0} elements".format(len(setBD)) if len(setBD) > 1 else "is {0} element".format(len(setBD))))
		print(setBD)
		bRet = False
	if setCD:
		print("There {0} in both Classification $C$ and Classification $D$. ".format("are {0} elements".format(len(setCD)) if len(setCD) > 1 else "is {0} element".format(len(setCD))))
		print(setCD)
		bRet = False
	
	# Git Push #
	if bRet:
		try:
			choice = input("Would you like to upload the files to GitHub via ``git`` [Yn]? ").upper() not in ("N", "NO", "0", "FALSE")
		except:
			choice = True
		if choice:
			bRet = updateSHA512(srcFolderPath) and gitPush()
	
	# Exit #
	iRet = EXIT_SUCCESS if bRet else EXIT_FAILURE
	print("Please press the enter key to exit ({0}). ".format(iRet))
	try:
		input()
	except:
		print()
	return iRet



if "__main__" == __name__:
	exit(main())