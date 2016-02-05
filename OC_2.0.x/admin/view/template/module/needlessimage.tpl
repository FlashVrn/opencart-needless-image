<?php echo $header; ?><?php echo $column_left; ?>
<div id="content">

<div id="content">
  <div class="page-header">
    <div class="container-fluid">
      <div class="pull-right">
        <button type="submit" form="form-needlessimage" data-toggle="tooltip" title="<?php echo $button_save; ?>" class="btn btn-primary"><i class="fa fa-save"></i></button>
        <a href="<?php echo $cancel; ?>" data-toggle="tooltip" title="<?php echo $button_cancel; ?>" class="btn btn-default"><i class="fa fa-reply"></i></a>
      </div>
      <h1><?php echo $heading_title; ?></h1>
      <ul class="breadcrumb">
        <?php foreach ($breadcrumbs as $breadcrumb) { ?>
        <li><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a></li>
        <?php } ?>
      </ul>
    </div>
  </div>
  <div class="container-fluid">
    <?php if ($error_warning) { ?>
    <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo $error_warning; ?>
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <?php } ?>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-pencil"></i>  <?php echo $heading_title; ?></h3>
      </div>
      <div class="panel-body">

			<form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="form-needlessimage" class="form-horizontal">
				<table id="directory" class="list">
					<thead>
						<tr>
							<td class="left"><?php echo $entry_directory; ?></td>
							<td class="left"><?php echo $entry_recursive; ?></td>
							<td></td>
						</tr>
					</thead>
					<?php foreach ($directories as $directory_row => $directory) { ?> 
						<tbody id="directory-row<?php echo $directory_row; ?>">
							<tr>
								<td class="left">
									<select name="directory[<?php echo $directory_row ?>][path]" class="form-control">
										<option value=""><?php echo $text_select_dir; ?></option>
										<?php foreach($directories_fs as $directory_fs) { ?> 
											<option value="<?php echo $directory_fs; ?>"<?php echo $directory_fs == $directory['path'] ? ' selected="selected"' : ''; ?>><?php echo $directory_fs; ?></option>
										<?php } ?>
									</select>
									<?php //print_r($directories_fs); ?>
								</td>
								<td class="left">
									<select name="directory[<?php echo $directory_row ?>][recursive]">
										<option value="0"><?php echo $text_no; ?></option>
										<option value="1"<?php echo $directory['recursive'] ? ' selected="selected"' : ''; ?>><?php echo $text_yes; ?></option>
									</select>
								</td>
								<td class="left">
									<a onclick="$('#directory-row<?php echo $directory_row; ?>').remove();" class="btn btn-primary"><?php echo $button_remove; ?></a>
								</td>
							</tr>
						</tbody>
					<?php } ?> 
					<tfoot>
						<tr>
							<td class="pull-left" colspan="2"><a onclick="addDirectory();" class="btn btn-primary" style=" padding: 2px 10px"><?php echo $button_add_dir; ?></a></td>
						</tr>
					</tfoot>
				</table>
			</form>
			<table id="analyze" class="list" style='width: 100%; text-align: center;'>
				<tfoot>
					<tr>
						<td class="pull-center">
							<a onclick="analyze();" class="btn btn-success" style="font-size:1.3em;"><?php echo $button_analyze; ?></a>
						</td>
					</tr>
				</tfoot>
			</table>
	</div>		
</div>
<script type="text/javascript"><!--
var directory_row = <?php echo isset($directory_row) ? ++$directory_row : 0; ?>;

function addDirectory() {
	var html = '';
	
	html  = '<tbody id="directory-row' + directory_row + '">';
	html += '	<tr>';
	html += '		<td class="left">';
	html += '			<select name="directory[' + directory_row + '][path]" id="directory' + directory_row + '">';
	html += '				<option value=""><?php echo $text_select_dir; ?></option>';
	<?php foreach($directories_fs as $directory_fs) { ?> 
	html += '				<option value="<?php echo $directory_fs; ?>"><?php echo $directory_fs; ?></option>';
	<?php } ?> 
	html += '			</select>';
	html += '		</td>';
	html += '		<td class="left">';
	html += '			<select name="directory[' + directory_row + '][recursive]">';
	html += '				<option value="0"><?php echo $text_no; ?></option>';
	html += '				<option value="1"><?php echo $text_yes; ?></option>';
	html += '			</select>';
	html += '		</td>';
	html += '		<td class="left">';
	html += '			<a onclick="$(\'#directory-row' + directory_row + '\').remove();" class="button"><?php echo $button_remove; ?></a>';
	html += '		</td>';
	html += '	</tr>';
	html += '</tbody>';
	
	$('#directory tfoot').before(html);
	
	directory_row++;
}

function analyze() {
	var post_data = $('#form-needlessimage').serialize();
	var html = '';
	var inner_html = '';
	
	$('#analyze thead, #analyze tbody').remove();
	
	$("#form-needlessimage select[name*='[path]']").each(function(index){
		html += '<thead id="analyze-head-' + index + '"' + ($(this).val() == '' ? ' style="display:none;"' : '') + '>';
		html += '	<tr>';
		html += '		<td class="left">' + $(this).val() + ($("#form-needlessimage select[name*='[" + index + "][recursive]']").val() == 1 ? ' <span style="font-weight:normal;">(+ <?php echo utf8_strtolower($entry_recursive); ?>)</span>' : '') + '</td>';
		html += '	</tr>';
		html += '</thead>';
		html += '<tbody id="analyze-body-' + index + '"' + ($(this).val() == '' ? ' style="display:none;"' : '') + '>';
		html += '	<tr>';
		html += '		<td class="center"><img src="view/image/loading.gif" class="loading"></td>';
		html += '	</tr>';
		html += '</tbody>';
	});
	
	$('#analyze tfoot').before(html);
	
	$.ajax({
		url: 'index.php?route=module/needlessimage/analyze&token=<?php echo $token; ?>',
		type: 'post',
		data: post_data,
		dataType: 'json',
		success: function(json) {
			if (json) {
				var dir_length = json.length;
				
				for (var i = 0; i < dir_length; i++) {
					files_length = json[i].length;
					if (files_length) {
						inner_html  = prepareCheckboxesForm(json[i], i);
					} else {
						inner_html = '<div class="attention" style="display: inline-block;"><?php echo $text_no_files_to_delete; ?></div>'
					}
					
					$('#analyze-body-' + i + ' td').html(inner_html);
				}
			} else {
				inner_html  = '<tbody>';
				inner_html += '	<tr>';
				inner_html += '		<td class="center"><div class="warning" style="display: inline-block;"><?php echo $error_error; ?></div></td>';
				inner_html += '	</tr>';
				inner_html += '</tbody>';
				
				$('#analyze thead, #analyze tbody').remove();
				$('#analyze tfoot').before(inner_html);
			}
		},
		error: function(xhr, ajaxOptions, thrownError) {
			alert(thrownError + "\r\n" + xhr.statusText + "\r\n" + xhr.responseText);
		}
	});
}

function deleteFiles(index) {
	var post_data = $('#form-delete-' + index).serialize();
	var html = '';
	
	$('#analyze-body-' + index + ' td').html('<img src="view/image/loading.gif" class="loading">');
	
	$.ajax({
		url: 'index.php?route=module/needlessimage/delete&token=<?php echo $token; ?>',
		type: 'post',
		data: post_data,
		dataType: 'json',
		success: function(json) {
			if (json.data.length) {
				html = prepareCheckboxesForm(json.data, index, json.message);
			} else {
				html = '<div style="display: inline-block;">' + json.message + '</div>';
			}
			
			$('#analyze-body-' + index + ' td').html(html);
		},
		error: function(xhr, ajaxOptions, thrownError) {
			alert(thrownError + "\r\n" + xhr.statusText + "\r\n" + xhr.responseText);
		}
	});
}

function prepareCheckboxesList(checkboxes) {
	var output = '<table width="100%" style="text-align: left">';
	var odd = 'odd';
	
	for (var i = 0; i < checkboxes.length; i++) {
		odd = odd == 'odd' ? 'even' : 'odd';
		output += '		<tr class="' + odd + '">';
		output += '			<td><input name="delete[]" type="checkbox" value="' + checkboxes[i]['path'] + '"> ' + checkboxes[i]['name']+"</td>";
		output += '		</tr>';
		
	}
	output += '</table>';
	return output;
}

function prepareCheckboxesForm(data, index, message) {
	var output = '';
	
	if (typeof message === 'undefined') {
		message = '';
	}
	
	output += '<form id="form-delete-' + index + '" action="<?php echo $action_delete ?>" method="post" enctype="multipart/form-data" class="left" style="display:inline-block;">';
	output += message;
	output += '	<input type="hidden" value="' + $("#form-needlessimage select[name*='[" + index + "][path]']").val() + '" name="path">';
	output += '	<input type="hidden" value="' + $("#form-needlessimage select[name*='[" + index + "][recursive]']").val() + '" name="recursive">';
	output += '	<div class="scrollbox">';
	output += prepareCheckboxesList(data);
	output += '	</div>';
	output += '	<div class="right">';
	output += '		<a onclick="deleteFiles(' + index + ');" class="button"><?php echo $button_delete_selected; ?></a> <a onclick="selectAll(\'#form-delete-' + index + '\');" class="button" style="background-color: #fff; color: #000; border: 1px solid #ddd; font-weight: bold;"><?php echo $button_select_all; ?></a> <a onclick="unselectAll(\'#form-delete-' + index + '\');" class="button" style="background-color: #fff; color: #000; border: 1px solid #ddd; font-weight: bold;"><?php echo $button_unselect_all; ?></a>';
	output += '	</div>';
	output += '</form>';
	
	return output;
}

function selectAll(form_id) {
	$(form_id).find(':checkbox').attr('checked', true);
}

function unselectAll(form_id) {
	$(form_id).find(':checkbox').attr('checked', false);
}
//--></script> 
<?php echo $footer; ?>