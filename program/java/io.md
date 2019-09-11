### InputStream转换String性能测试 ###

[原文地址](https://www.cnblogs.com/milton/p/6366916.html)

> 1.使用IOUtils.toString (Apache Utils)

	String result = IOUtils.toString(inputStream, StandardCharsets.UTF_8);

> 2.使用CharStreams (guava)

	String result = CharStreams.toString(new InputStreamReader(inputStream, Charsets.UTF_8));

> 3.使用Scanner (JDK)

	Scanner s = new Scanner(inputStream).useDelimiter("\\A");
	String result = s.hasNext() ? s.next() : "";

> 4.使用Stream Api (Java 8). 

提醒: 这种方式会将不同的换行符 (比如\r\n) 都替换为 \n.

	String result = new BufferedReader(new InputStreamReader(inputStream)).lines().collect(Collectors.joining("\n"));

> 5.使用parallel Stream Api (Java 8). 

提醒: 这种方式会将不同的换行符 (比如\r\n) 都替换为 \n.

	String result = new BufferedReader(new InputStreamReader(inputStream)).lines().parallel().collect(Collectors.joining("\n"));

> 6.使用InputStreamReader 和StringBuilder (JDK)

	final int bufferSize = 1024;
	final char[] buffer = new char[bufferSize];
	final StringBuilder out = new StringBuilder();
	Reader in = new InputStreamReader(inputStream, "UTF-8");
	for (; ; ) {
	    int rsz = in.read(buffer, 0, buffer.length);
	    if (rsz < 0)
	        break;
	    out.append(buffer, 0, rsz);
	}
	return out.toString();

> 7.使用StringWriter 和 IOUtils.copy (Apache Commons)

	StringWriter writer = new StringWriter();
	IOUtils.copy(inputStream, writer, "UTF-8");
	return writer.toString();

> 8.使用ByteArrayOutputStream 和 inputStream.read (JDK)

	ByteArrayOutputStream result = new ByteArrayOutputStream();
	byte[] buffer = new byte[1024];
	int length;
	while ((length = inputStream.read(buffer)) != -1) {
	    result.write(buffer, 0, length);
	}
	return result.toString("UTF-8");

> 9.使用BufferedReader (JDK). 

提醒: 这种方式会将不同的换行符 (比如\r\n) 都替换为当前系统的换行符(例如, 在windows下是"\r\n").

	String newLine = System.getProperty("line.separator");
	BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
	StringBuilder result = new StringBuilder();
	String line; boolean flag = false;
	while ((line = reader.readLine()) != null) {
	    result.append(flag? newLine: "").append(line);
	    flag = true;
	}
	return result.toString();

> 10.使用BufferedInputStream 和 ByteArrayOutputStream (JDK)

	BufferedInputStream bis = new BufferedInputStream(inputStream);
	ByteArrayOutputStream buf = new ByteArrayOutputStream();
	int result = bis.read();
	while(result != -1) {
	    buf.write((byte) result);
	    result = bis.read();
	}
	return buf.toString();

> 10.使用 inputStream.read() 和 StringBuilder (JDK). 

提醒: 这种方式处理Unicode时存在问题, 例如俄文, 仅在非Unicode字符串下工作正常.

	int ch;
	StringBuilder sb = new StringBuilder();
	while((ch = inputStream.read()) != -1)
	    sb.append((char)ch);
	reset();
	return sb.toString();

**声明：**

方式 4, 5 和 9 都存在替换换行符的问题. 方式11在Unicode下不能正常工作.

**性能测试**

对于短字符串 (length = 175)的测试, url in github (mode = Average Time, system = Linux, score 1,343 is the best):

	Benchmark                        Mode  Cnt   Score   Error  Units
	8. ByteArrayOutputStream and read (JDK)        avgt   10   1,343 ± 0,028  us/op
	6. InputStreamReader and StringBuilder (JDK)   avgt   10   6,980 ± 0,404  us/op
	10.BufferedInputStream, ByteArrayOutputStream  avgt   10   7,437 ± 0,735  us/op
	11.InputStream.read() and StringBuilder (JDK)  avgt   10   8,977 ± 0,328  us/op
	7. StringWriter and IOUtils.copy (Apache)      avgt   10  10,613 ± 0,599  us/op
	1. IOUtils.toString (Apache Utils)             avgt   10  10,605 ± 0,527  us/op
	3. Scanner (JDK)                               avgt   10  12,083 ± 0,293  us/op
	2. CharStreams (guava)                         avgt   10  12,999 ± 0,514  us/op
	4. Stream Api (Java 8)                         avgt   10  15,811 ± 0,605  us/op
	9. BufferedReader (JDK)                        avgt   10  16,038 ± 0,711  us/op
	5. parallel Stream Api (Java 8)                avgt   10  21,544 ± 0,583  us/op

对于长字符串的测试 (length = 50100), url in github (mode = Average Time, system = Linux, score 200,715 is the best):

	Benchmark                        Mode  Cnt   Score        Error  Units
	8. ByteArrayOutputStream and read (JDK)        avgt   10   200,715 ±   18,103  us/op
	1. IOUtils.toString (Apache Utils)             avgt   10   300,019 ±    8,751  us/op
	6. InputStreamReader and StringBuilder (JDK)   avgt   10   347,616 ±  130,348  us/op
	7. StringWriter and IOUtils.copy (Apache)      avgt   10   352,791 ±  105,337  us/op
	2. CharStreams (guava)                         avgt   10   420,137 ±   59,877  us/op
	9. BufferedReader (JDK)                        avgt   10   632,028 ±   17,002  us/op
	5. parallel Stream Api (Java 8)                avgt   10   662,999 ±   46,199  us/op
	4. Stream Api (Java 8)                         avgt   10   701,269 ±   82,296  us/op
	10.BufferedInputStream, ByteArrayOutputStream  avgt   10   740,837 ±    5,613  us/op
	3. Scanner (JDK)                               avgt   10   751,417 ±   62,026  us/op
	11.InputStream.read() and StringBuilder (JDK)  avgt   10  2919,350 ± 1101,942  us/op

**结论**

可以看出8和6是相对更好的选择

**应用**

![](./images/io-test.png)


	#入参
	org.springframework.core.io.Resource resource = new ClassPathResource("example/http-server.conf.example");