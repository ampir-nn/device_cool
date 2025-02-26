#! /vendor/bin/sh

# Copyright (c) 2009-2016, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`
low_ram=`getprop ro.config.low_ram`
if [ -f /sys/devices/soc0/soc_id ]; then
    platformid=`cat /sys/devices/soc0/soc_id`
else
    platformid=`cat /sys/devices/system/soc/soc0/id`
fi
#
# Function to start sensors for DSPS enabled platforms
#
start_sensors()
{
    if [ -c /dev/msm_dsps -o -c /dev/sensors ]; then
        chmod -h 775 /persist/sensors
        chmod -h 664 /persist/sensors/sensors_settings
        chown -h system.root /persist/sensors/sensors_settings

        mkdir -p /data/misc/sensors
        chmod -h 775 /data/misc/sensors

        start vendor.sensors
    fi
}

start_battery_monitor()
{
	if ls /sys/bus/spmi/devices/qpnp-bms-*/fcc_data ; then
		chown -h root.system /sys/module/pm8921_bms/parameters/*
		chown -h root.system /sys/module/qpnp_bms/parameters/*
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_data
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_temp
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_chgcyl
		chmod 0660 /sys/module/qpnp_bms/parameters/*
		chmod 0660 /sys/module/pm8921_bms/parameters/*
		mkdir -p /data/bms
		chown -h root.system /data/bms
		chmod 0770 /data/bms
		start battery_monitor
	fi
}

start_charger_monitor()
{
	if ls /sys/module/qpnp_charger/parameters/charger_monitor; then
		chown -h root.system /sys/module/qpnp_charger/parameters/*
		chown -h root.system /sys/class/power_supply/battery/input_current_max
		chown -h root.system /sys/class/power_supply/battery/input_current_trim
		chown -h root.system /sys/class/power_supply/battery/input_current_settled
		chown -h root.system /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/class/power_supply/battery/input_current_max
		chmod 0664 /sys/class/power_supply/battery/input_current_trim
		chmod 0664 /sys/class/power_supply/battery/input_current_settled
		chmod 0664 /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/module/qpnp_charger/parameters/charger_monitor
		start charger_monitor
	fi
}

start_vm_bms()
{
	if [ -e /dev/vm_bms ]; then
		chown -h root.system /sys/class/power_supply/bms/current_now
		chown -h root.system /sys/class/power_supply/bms/voltage_ocv
		chmod 0664 /sys/class/power_supply/bms/current_now
		chmod 0664 /sys/class/power_supply/bms/voltage_ocv
		start vm_bms
	fi
}

start_msm_irqbalance_8939()
{
	if [ -f /vendor/bin/msm_irqbalance ]; then
		case "$platformid" in
		    "239" | "293" | "294" | "295" | "304" | "313" | "338" | "351" )
			start vendor.msm_irqbalance;;
		esac
	fi
}

start_msm_irqbalance_8952()
{
        if [ -f /vendor/bin/msm_irqbalance ]; then
                case "$platformid" in
                     "241" | "263" | "264" | "268" | "269" | "270" | "271")
                        start vendor.msm_irqbalance;;
                esac
                case "$platformid" in
                     "266" | "274" | "277" | "278")
                        start vendor.msm_irqbal_lb;;
                esac
	fi
}

start_msm_irqbalance660()
{
	if [ -f /vendor/bin/msm_irqbalance ]; then
		case "$platformid" in
		    "317" | "324" | "325" | "326" | "345" | "346")
			start vendor.msm_irqbalance;;
		    "318" | "327")
			start vendor.msm_irqbl_sdm630;;
		esac
	fi
}

start_msm_irqbalance()
{
	if [ -f /vendor/bin/msm_irqbalance ]; then
		start vendor.msm_irqbalance
	fi
}

start_copying_prebuilt_qcril_db()
{
    if [ -f /vendor/radio/qcril_database/qcril.db -a ! -f /data/vendor/radio/qcril.db ]; then
        cp /vendor/radio/qcril_database/qcril.db /data/vendor/radio/qcril.db
        chown -h radio.radio /data/vendor/radio/qcril.db
    fi
}

baseband=`getprop ro.baseband`
echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra_defrtr

case "$baseband" in
        "svlte2a")
        start bridgemgrd
        ;;
esac

cp -f /etc/sensors/sensors_dbg_config.txt /persist/sensors/sensors_dbg_config.txt
chmod 664 /persist/sensors/sensors_dbg_config.txt

start_sensors
start_copying_prebuilt_qcril_db

if [ -f /sys/class/graphics/fb0/modes ]; then
	panel_res=`cat /sys/class/graphics/fb0/modes`
	if [ "${panel_res:5:1}" == "x" ]; then
		panel_xres=${panel_res:2:3}
	else
		panel_xres=${panel_res:2:4}
	fi
fi

case "$target" in
    "msm7630_surf" | "msm7630_1x" | "msm7630_fusion")
        if [ -f /sys/devices/soc0/hw_platform ]; then
            value=`cat /sys/devices/soc0/hw_platform`
        else
            value=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$value" in
            "Fluid")
             start profiler_daemon;;
        esac
        ;;
    "msm8660" )
        if [ -f /sys/devices/soc0/hw_platform ]; then
            platformvalue=`cat /sys/devices/soc0/hw_platform`
        else
            platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$platformvalue" in
            "Fluid")
                start profiler_daemon;;
        esac
        ;;
    "msm8960")
        case "$baseband" in
            "msm")
                start_battery_monitor;;
        esac

        if [ -f /sys/devices/soc0/hw_platform ]; then
            platformvalue=`cat /sys/devices/soc0/hw_platform`
        else
            platformvalue=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        ;;
    "msm8974")
        platformvalue=`cat /sys/devices/soc0/hw_platform`
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        case "$baseband" in
            "msm")
                start_battery_monitor
                ;;
        esac
        start_charger_monitor
        ;;
    "sdm660")
        if [ -f /sys/devices/soc0/soc_id ]; then
             soc_id=`cat /sys/devices/soc0/soc_id`
        else
             soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi

        case "$soc_id" in
             "317" | "324" | "325" | "326" | "318" | "327" )
                  case "$hw_platform" in
                       "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "QRD")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                  esac
                  ;;
       esac
        start_msm_irqbalance660
        ;;
    "apq8084")
        platformvalue=`cat /sys/devices/soc0/hw_platform`
        case "$platformvalue" in
             "Fluid")
                 start profiler_daemon;;
             "Liquid")
                 start profiler_daemon;;
        esac
        ;;
    "msm8226")
        start_charger_monitor
        ;;
    "msm8610")
        start_charger_monitor
        ;;
    "msm8916")
        start_vm_bms
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/platform_subtype_id ]; then
             platform_subtype_id=`cat /sys/devices/soc0/platform_subtype_id`
        fi
        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        fi
        case "$soc_id" in
             "239")
                  case "$hw_platform" in
                       "Surf")
                            case "$platform_subtype_id" in
                                 "1")
                                      setprop qemu.hw.mainkeys 0
                                      ;;
                            esac
                            ;;
                       "MTP")
                          case "$platform_subtype_id" in
                               "3")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                          esac
                          ;;
                  esac
                  ;;
        esac
        ;;
    "msm8994" | "msm8992" | "msm8998" | "apq8098_latv" | "sdm845")
        start_msm_irqbalance
        ;;
    "msm8996")
        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        fi
        case "$hw_platform" in
                "MTP" | "CDP")
                #Loop through the sysfs nodes and determine the correct sysfs to change the permission and ownership.
                        for count in 0 1 2 3 4 5 6 7 8 9 10
                        do
                                dir="/sys/devices/soc/75ba000.i2c/i2c-12/12-0020/input/input"$count
                                if [ -d "$dir" ]; then
                                     chmod 0660 $dir/secure_touch_enable
                                     chmod 0440 $dir/secure_touch
                                     chown system.drmrpc $dir/secure_touch_enable
                                     chown system.drmrpc $dir/secure_touch
                                     break
                                fi
                        done
                        ;;
        esac
        ;;
    "msm8909")
        start_vm_bms
        ;;
    "msm8952")
        start_msm_irqbalance_8952
	 if [ -f /sys/devices/soc0/soc_id ]; then
             soc_id=`cat /sys/devices/soc0/soc_id`
         else
             soc_id=`cat /sys/devices/system/soc/soc0/id`
         fi

	 if [ -f /sys/devices/soc0/platform_subtype_id ]; then
	      platform_subtype_id=`cat /sys/devices/soc0/platform_subtype_id`
	 fi
	 if [ -f /sys/devices/soc0/hw_platform ]; then
	       hw_platform=`cat /sys/devices/soc0/hw_platform`
	 fi
	 case "$soc_id" in
	      "264")
	           case "$hw_platform" in
			    "Surf")
			         case "$platform_subtype_id" in
			              "1" | "2")
			                  setprop qemu.hw.mainkeys 0
			                  ;;
				  esac
			          ;;
			    "MTP")
			         case "$platform_subtype_id" in
			              "3")
			                  setprop qemu.hw.mainkeys 0
			                  ;;
				  esac
			          ;;
			    "QRD")
			         case "$platform_subtype_id" in
			              "0")
			                   # setprop qemu.hw.mainkeys 0
			                  ;;
				  esac
				  ;;
		     esac
		     ;;
		 "266" | "274" | "277" | "278")
	              case "$hw_platform" in
			       "Surf" | "RCM")
                                    if [ $panel_xres -eq 1440 ]; then
				       setprop qemu.hw.mainkeys 0
				    fi
				    ;;
				"MTP" | "QRD")
				        # setprop qemu.hw.mainkeys 0
				       ;;
		      esac
		      ;;
	esac
	;;
    "msm8937")
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
	if [ "$low_ram" != "true" ]; then
             case "$soc_id" in
                  "294" | "295" | "303" | "307" | "308" | "309" | "313" | "320")
                       case "$hw_platform" in
                            "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "QRD")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       esac
                       ;;
             esac
        fi
        ;;
    "msm8953")
	start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
        case "$soc_id" in
             "293" | "304" | "338" | "351" | "349" | "350" )
                  case "$hw_platform" in
                       "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       "QRD")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                  esac
                  ;;
       esac
        ;;
esac

#
# Make modem config folder and copy firmware config to that folder
#
#rm -rf /data/misc/radio/modem_config
#mkdir /data/misc/radio/modem_config
#chmod 770 /data/misc/radio/modem_config
#cp -r /firmware/image/modem_pr/mbn_ota/* /data/misc/radio/modem_config
#chown -hR radio.radio /data/misc/radio/modem_config
#echo 1 > /data/misc/radio/copy_complete
rm -rf /data/vendor/radio/modem_config/mcfg_sw
mkdir -p /data/vendor/radio/modem_config/mcfg_sw
chmod 770 /data/vendor/radio/modem_config
chmod 770 /data/vendor/radio/modem_config/mcfg_sw
product_name=`getprop ro.product.name`

case "$product_name" in
    "Le2_CN" | "Le2_CU" | "Le2_CM" | "Le2_HK")
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/cmcc.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/ct.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/cu.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/row.mbn /data/vendor/radio/modem_config/mcfg_sw
    ;;
    "Le2_NA")
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/att.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/tmo.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/row.mbn /data/vendor/radio/modem_config/mcfg_sw
    ;;
    "Le2_WW")
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/rjil.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/row.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/cmcc.mbn /data/vendor/radio/modem_config/mcfg_sw
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/cu.mbn /data/vendor/radio/modem_config/mcfg_sw
    ;;
    *)
    cp -r /firmware/image/modem_pr/mcfg/configs/mcfg_sw/generic/mbn_ota/row.mbn /data/vendor/radio/modem_config/mcfg_sw
    ;;
esac
chmod 770 /data/vendor/radio/modem_config/mcfg_sw/*
chown -hR radio.radio /data/vendor/radio/modem_config
chown -hR radio.radio /data/vendor/radio/modem_config/mcfg_sw
cp /firmware/verinfo/ver_info.txt /data/vendor/radio/ver_info.txt
chown radio.radio /data/vendor/radio/ver_info.txt
echo 1 > /data/vendor/radio/copy_complete

#check build variant for printk logging
#current default minimum boot-time-default
buildvariant=`getprop ro.build.type`
case "$buildvariant" in
    "userdebug" | "eng")
        #set default loglevel to KERN_INFO
        echo "6 6 1 7" > /proc/sys/kernel/printk
        ;;
    *)
        #set default loglevel to KERN_WARNING
        echo "4 4 1 4" > /proc/sys/kernel/printk
        ;;
esac
