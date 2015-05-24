# NodeCategories
MySQL节点无限分类表

## 说明

在基础无限分类表的结构上，加入记录每层节点id的字符串作为扩展，避免递归查询操作，以便快速搜索出目标分类树。

优点：和一般的递归相比，效率有所提升，操作简单。

缺点：以空间换取时间，而且是匹配字符串操作，如果分类树巨大显得性能不足，适合中小型分类树。

例子：

如果有以下的地区表，在基本的parent_id上，加入node_index字段，保存每级节点id

<table>
<tr>
<td>id</td>
<td>parent_id</td>
<td>level</td>
<td>name</td>
<td>node_index</td>
</tr>

<tr>
<td>19</td>
<td>0</td>
<td>1</td>
<td>广东省</td>
<td>,0,19,</td>
</tr>

<tr>
<td>289</td>
<td>19</td>
<td>2</td>
<td>广州市</td>
<td>,0,19,289,</td>
</tr>

<tr>
<td>291</td>
<td>19</td>
<td>2</td>
<td>深圳市</td>
<td>,0,19,291,</td>
</tr>

<tr>
<td>3040</td>
<td>289</td>
<td>3</td>
<td>天河区</td>
<td>,0,19,289,3040,</td>
</tr>

<tr>
<td>3041</td>
<td>289</td>
<td>3</td>
<td>海珠区</td>
<td>,0,19,289,3041,</td>
</tr>

<tr>
<td>29014</td>
<td>3040</td>
<td>4</td>
<td>员村街道</td>
<td>,0,19,289,3040,29014,</td>
</tr>

</table>

那么，如果需要搜索parent_id为289的“广州市”下所有子地区分类，可以使用以下SQL：

	SELECT * FROM `category_has_node` WHERE `node_index` LIKE ',0,19,289,%';


## 表结构

主数据表名称为category，默认存储引擎MyISAM

扩展表名称为category_node_index，默认存储引擎MyISAM，其中node_index字段使用了全文索引

视图名称为category_has_node

_可根据需要自行修改 ，修改表名需要同时修改触发器内的表名_

默认结构为：
	
	CREATE TABLE IF NOT EXISTS  `category` (
	  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `parent_id` int(11) unsigned NOT NULL DEFAULT '0',
	  `level` smallint(5) unsigned NOT NULL DEFAULT '1',
	  `name` varchar(60) NOT NULL,
	  PRIMARY KEY (`id`),
	  KEY `idx_parent_id` (`parent_id`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;

	CREATE TABLE IF NOT EXISTS `category_node_index` (
	  `id` int(10) unsigned NOT NULL,
	  `node_index` varchar(500) NOT NULL,
	  PRIMARY KEY (`id`),
	  FULLTEXT KEY `idx_node_index` (`node_index`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8;

## 视图
* category_has_node category表和category_node_index内联查询

## 触发器

* before_insert_category 用于计算level字段和检查父节点id是否存在
* after_insert_category 用于创建node_index
* before_update_category 用于更新level字段和检查新的节点是否为自己的子节点
* after_update_category 用于更新本身及属下节点的node_index

## 存储过程

_由于MySQL触发器不能操作本表，无法删除同一个表内的数据和递归删除，暂时没有太好的解决方法，暂时先用存储过程实现_

* delete_category_procedure 删除节点及所有子节点

调用：

	CALL delete_category_procedure(parent_id);



## 测试数据

pre_common_district.sql 文件为[Discuz! X](http://www.comsenz.com/products/discuz/)默认数据库中的地区表的数据和结构

导入测试数据：

	INSERT INTO `category` (`parent_id`, `level`, `name`) 
	SELECT `upid`, `level`, `name` FROM `pre_common_district`;
